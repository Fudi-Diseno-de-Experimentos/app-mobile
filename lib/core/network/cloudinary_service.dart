import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'cloudinary_config.dart';

/// Servicio para manejo de subida de imágenes con Cloudinary
class CloudinaryService {
  CloudinaryService();

  /// 📤 Subir imagen a Cloudinary
  ///
  /// [imagePath] - Ruta del archivo de imagen
  /// [imageType] - Tipo de imagen (avatar, chat, announcement)
  /// [onProgress] - Callback para el progreso de subida (opcional)
  Future<String?> uploadImage(
    String imagePath, {
    ImageType imageType = ImageType.announcement,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('🚀 CloudinaryService: Iniciando subida de imagen...');
      debugPrint('📁 Archivo: $imagePath');
      debugPrint('🎯 Tipo: $imageType');

      final config = CloudinaryConfig.getConfigForType(imageType);

      // 📏 Validar tamaño del archivo
      final file = File(imagePath);
      final fileSize = await file.length();
      debugPrint('📊 Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      if (fileSize > config.maxSize) {
        debugPrint('❌ Archivo demasiado grande: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB > ${(config.maxSize / 1024 / 1024).toStringAsFixed(2)} MB');
        throw Exception('Image too large. Maximum ${(config.maxSize / 1024 / 1024).toStringAsFixed(1)}MB');
      }

      // 🗜️ Comprimir imagen si es necesario (opcional, podrías omitirlo si prefieres subir el original)
      final compressedPath = await _compressImageIfNeeded(imagePath, config, imageType);
      debugPrint('🗜️ Imagen comprimida: $compressedPath');

      // 🔄 Configurar cloudinary para este tipo específico
      final cloudinary = CloudinaryPublic(
        CloudinaryConfig.cloudName,
        config.uploadPreset,
        cache: false,
      );

      // 📤 Realizar subida
      onProgress?.call(0.1); // 10% - Iniciando subida

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          compressedPath,
          folder: config.folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      onProgress?.call(1.0); // 100% - Completado

      debugPrint('✅ Imagen subida exitosamente');
      debugPrint('🔗 URL: ${response.secureUrl}');

      // 🧹 Limpiar archivo temporal si se creó uno comprimido
      if (compressedPath != imagePath) {
        try {
          await File(compressedPath).delete();
          debugPrint('🧹 Archivo temporal eliminado');
        } catch (e) {
          debugPrint('⚠️ Error al eliminar archivo temporal: $e');
        }
      }

      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ Error en CloudinaryService.uploadImage: $e');
      return null;
    }
  }

  /// 🗜️ Comprimir imagen si excede el tamaño máximo o es muy grande.
  ///
  /// Preserva el formato de origen para evitar corrupción:
  /// - GIF/WebP nunca se transcodifican (un GIF perdería su animación y
  ///   WebP suele fallar al decodificar). El chequeo de tamaño duro previo
  ///   ya garantiza `fileSize <= config.maxSize`, así que el original es
  ///   seguro de subir tal cual.
  /// - PNG se re-encoda como PNG (encodear PNG→JPG vuelve negra la
  ///   transparencia).
  /// - JPEG/otros usan el bucle de calidad JPG.
  /// - Avatares se recortan a cuadrado (sin estirar/distorsionar).
  Future<String> _compressImageIfNeeded(
    String imagePath,
    ImageConfig config,
    ImageType imageType,
  ) async {
    final file = File(imagePath);
    final fileSize = await file.length();
    final ext = imagePath.split('.').last.toLowerCase();

    // Formatos animados / con alfa por intención: no transcodificar.
    if (ext == 'gif' || ext == 'webp') {
      return imagePath;
    }

    final isPng = ext == 'png';

    // Si el archivo ya es pequeño, retornar el original
    if (fileSize <= config.maxSize && fileSize < 512 * 1024) {
      return imagePath;
    }

    try {
      debugPrint('🗜️ Comprimiendo imagen...');

      // 📖 Leer imagen
      final imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        // No se pudo decodificar → no arriesgar un re-encode corrupto.
        debugPrint('⚠️ No se pudo decodificar; subiendo original sin tocar.');
        return imagePath;
      }

      if (imageType == ImageType.avatar) {
        // ✂️ Recorte cuadrado centrado (sin estirar) y tamaño 512.
        image = img.copyResizeCropSquare(image, size: 512);
      } else {
        // 📐 Redimensionar manteniendo proporción
        final (targetWidth, targetHeight) =
            _getTargetDimensions(imageType, image);
        if (image.width > targetWidth || image.height > targetHeight) {
          image = img.copyResize(
            image,
            width: targetWidth,
            height: targetHeight,
            interpolation: img.Interpolation.linear,
          );
          debugPrint('📐 Redimensionada a: ${image.width}x${image.height}');
        }
      }

      late Uint8List outBytes;
      late String outExt;

      if (isPng) {
        // Mantener alfa — PNG→JPG volvería negra la transparencia.
        outBytes = Uint8List.fromList(img.encodePng(image));
        outExt = 'png';
      } else {
        // 💾 Comprimir con calidad variable hasta alcanzar tamaño objetivo
        int quality = 85;
        Uint8List bytes;
        do {
          bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
          debugPrint(
            '🎛️ Calidad $quality: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
          );
          if (bytes.length <= config.maxSize || quality <= 30) break;
          quality -= 15;
        } while (bytes.length > config.maxSize);
        outBytes = bytes;
        outExt = 'jpg';
      }

      // 📁 Guardar archivo comprimido temporalmente
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$outExt',
      );
      await compressedFile.writeAsBytes(outBytes);

      debugPrint(
        '✅ Imagen comprimida final: ${(outBytes.length / 1024 / 1024).toStringAsFixed(2)} MB ($outExt)',
      );

      return compressedFile.path;
    } catch (e) {
      debugPrint('❌ Error al comprimir imagen: $e');
      // En caso de error, retornar el archivo original
      return imagePath;
    }
  }

  /// 📐 Obtener dimensiones objetivo según tipo de imagen
  (int, int) _getTargetDimensions(ImageType imageType, img.Image image) {
    switch (imageType) {
      case ImageType.avatar:
        return (512, 512); // Cuadrado para avatares
      case ImageType.chat:
        // Mantener proporción, máximo 1024px en el lado más largo
        final aspectRatio = image.width / image.height;
        if (aspectRatio > 1) {
          return (1024, (1024 / aspectRatio).round());
        } else {
          return ((1024 * aspectRatio).round(), 1024);
        }
      case ImageType.announcement:
        // Mantener proporción, máximo 1200px en el lado más largo
        final aspectRatio = image.width / image.height;
        if (aspectRatio > 1) {
          return (1200, (1200 / aspectRatio).round());
        } else {
          return ((1200 * aspectRatio).round(), 1200);
        }
    }
  }

  /// 🧹 Limpiar archivos temporales
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && 
            (file.path.contains('compressed_') || 
             file.path.contains('temp_image_'))) {
          await file.delete();
        }
      }

      debugPrint('🧹 Archivos temporales limpiados');
    } catch (e) {
      debugPrint('⚠️ Error al limpiar archivos temporales: $e');
    }
  }
}
