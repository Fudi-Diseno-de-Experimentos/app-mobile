import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
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
      print('🚀 CloudinaryService: Iniciando subida de imagen...');
      print('📁 Archivo: $imagePath');
      print('🎯 Tipo: $imageType');

      final config = CloudinaryConfig.getConfigForType(imageType);

      // 📏 Validar tamaño del archivo
      final file = File(imagePath);
      final fileSize = await file.length();
      print('📊 Tamaño del archivo: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      if (fileSize > config.maxSize) {
        print('❌ Archivo demasiado grande: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB > ${(config.maxSize / 1024 / 1024).toStringAsFixed(2)} MB');
        throw Exception('Imagen demasiado grande. Máximo ${(config.maxSize / 1024 / 1024).toStringAsFixed(1)}MB');
      }

      // 🗜️ Comprimir imagen si es necesario (opcional, podrías omitirlo si prefieres subir el original)
      final compressedPath = await _compressImageIfNeeded(imagePath, config, imageType);
      print('🗜️ Imagen comprimida: $compressedPath');

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

      print('✅ Imagen subida exitosamente');
      print('🔗 URL: ${response.secureUrl}');

      // 🧹 Limpiar archivo temporal si se creó uno comprimido
      if (compressedPath != imagePath) {
        try {
          await File(compressedPath).delete();
          print('🧹 Archivo temporal eliminado');
        } catch (e) {
          print('⚠️ Error al eliminar archivo temporal: $e');
        }
      }

      return response.secureUrl;
    } catch (e) {
      print('❌ Error en CloudinaryService.uploadImage: $e');
      return null;
    }
  }

  /// 🗜️ Comprimir imagen si excede el tamaño máximo o es muy grande
  Future<String> _compressImageIfNeeded(String imagePath, ImageConfig config, ImageType imageType) async {
    final file = File(imagePath);
    final fileSize = await file.length();

    // Si el archivo ya es pequeño, retornar el original
    if (fileSize <= config.maxSize && fileSize < 512 * 1024) {
      return imagePath;
    }

    try {
      print('🗜️ Comprimiendo imagen...');

      // 📖 Leer imagen
      final imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // 📐 Calcular nuevas dimensiones según el tipo
      final (targetWidth, targetHeight) = _getTargetDimensions(imageType, image);

      // ✂️ Redimensionar imagen manteniendo proporción
      if (image.width > targetWidth || image.height > targetHeight) {
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
        print('📐 Redimensionada a: ${image.width}x${image.height}');
      }

      // 💾 Comprimir con calidad variable hasta alcanzar tamaño objetivo
      int quality = 85;
      Uint8List? compressedBytes;

      do {
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality)
        );

        print('🎛️ Calidad $quality: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

        if (compressedBytes.length <= config.maxSize || quality <= 30) {
          break;
        }

        quality -= 15; // Reducir calidad gradualmente
      } while (compressedBytes.length > config.maxSize);

      // 📁 Guardar archivo comprimido temporalmente
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      print('✅ Imagen comprimida final: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

      return compressedFile.path;
    } catch (e) {
      print('❌ Error al comprimir imagen: $e');
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

      print('🧹 Archivos temporales limpiados');
    } catch (e) {
      print('⚠️ Error al limpiar archivos temporales: $e');
    }
  }
}
