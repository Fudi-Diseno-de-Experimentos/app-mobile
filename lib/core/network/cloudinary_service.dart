import 'dart:io';

import 'package:app_mobile/core/network/cloudinary_config.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image upload service backed by Cloudinary unsigned presets.
class CloudinaryService {
  CloudinaryService();

  /// Uploads an image to Cloudinary.
  ///
  /// [imagePath] - Path to the image file.
  /// [imageType] - Image kind (avatar, chat, announcement, company).
  /// [onProgress] - Optional upload progress callback.
  Future<String?> uploadImage(
    String imagePath, {
    ImageType imageType = ImageType.announcement,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('🚀 CloudinaryService: starting image upload...');
      debugPrint('📁 File: $imagePath');
      debugPrint('🎯 Type: $imageType');

      final config = CloudinaryConfig.getConfigForType(imageType);

      // Validate file size
      final file = File(imagePath);
      final fileSize = await file.length();
      debugPrint('📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      if (fileSize > config.maxSize) {
        debugPrint('❌ File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB > ${(config.maxSize / 1024 / 1024).toStringAsFixed(2)} MB');
        throw Exception('Image too large. Maximum ${(config.maxSize / 1024 / 1024).toStringAsFixed(1)}MB');
      }

      // Compress the image if needed before uploading
      final compressedPath = await _compressImageIfNeeded(imagePath, config, imageType);
      debugPrint('🗜️ Compressed image: $compressedPath');

      // Configure Cloudinary for this image type
      final cloudinary = CloudinaryPublic(
        CloudinaryConfig.cloudName,
        config.uploadPreset,
        cache: false,
      );

      // Upload
      onProgress?.call(0.1); // 10% - upload starting

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          compressedPath,
          folder: config.folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      onProgress?.call(1.0); // 100% - done

      debugPrint('✅ Image uploaded successfully');
      debugPrint('🔗 URL: ${response.secureUrl}');

      // Clean up the temporary file if a compressed copy was created
      if (compressedPath != imagePath) {
        try {
          await File(compressedPath).delete();
          debugPrint('🧹 Temporary file deleted');
        } catch (e) {
          debugPrint('⚠️ Failed to delete temporary file: $e');
        }
      }

      return response.secureUrl;
    } catch (e) {
      debugPrint('❌ Error in CloudinaryService.uploadImage: $e');
      return null;
    }
  }

  /// Compresses the image when it exceeds the maximum size or is very large.
  ///
  /// Preserves the source format to avoid corruption:
  /// - GIF/WebP are never transcoded (a GIF would lose its animation and
  ///   WebP often fails to decode). The hard size check before this call
  ///   already guarantees `fileSize <= config.maxSize`, so the original is
  ///   safe to upload as-is.
  /// - PNG is re-encoded as PNG (encoding PNG→JPG turns transparency black).
  /// - JPEG/others use the JPG quality loop.
  /// - Avatars are cropped to a square (no stretching/distortion).
  Future<String> _compressImageIfNeeded(
    String imagePath,
    ImageConfig config,
    ImageType imageType,
  ) async {
    final file = File(imagePath);
    final fileSize = await file.length();
    final ext = imagePath.split('.').last.toLowerCase();

    // Animated / intentionally-alpha formats: never transcode.
    if (ext == 'gif' || ext == 'webp') {
      return imagePath;
    }

    final isPng = ext == 'png';

    // Already small enough: keep the original.
    if (fileSize <= config.maxSize && fileSize < 512 * 1024) {
      return imagePath;
    }

    try {
      debugPrint('🗜️ Compressing image...');

      final imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        // Could not decode: do not risk a corrupt re-encode.
        debugPrint('⚠️ Could not decode; uploading original untouched.');
        return imagePath;
      }

      if (imageType == ImageType.avatar) {
        // Centered square crop (no stretching), 512px.
        image = img.copyResizeCropSquare(image, size: 512);
      } else {
        // Resize keeping aspect ratio
        final (targetWidth, targetHeight) =
            _getTargetDimensions(imageType, image);
        if (image.width > targetWidth || image.height > targetHeight) {
          image = img.copyResize(
            image,
            width: targetWidth,
            height: targetHeight,
            interpolation: img.Interpolation.linear,
          );
          debugPrint('📐 Resized to: ${image.width}x${image.height}');
        }
      }

      late Uint8List outBytes;
      late String outExt;

      if (isPng) {
        // Keep alpha — PNG→JPG would turn transparency black.
        outBytes = Uint8List.fromList(img.encodePng(image));
        outExt = 'png';
      } else {
        // Compress with decreasing quality until the target size is reached
        int quality = 85;
        Uint8List bytes;
        do {
          bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
          debugPrint(
            '🎛️ Quality $quality: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
          );
          if (bytes.length <= config.maxSize || quality <= 30) break;
          quality -= 15;
        } while (bytes.length > config.maxSize);
        outBytes = bytes;
        outExt = 'jpg';
      }

      // Save the compressed file to a temporary location
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$outExt',
      );
      await compressedFile.writeAsBytes(outBytes);

      debugPrint(
        '✅ Final compressed image: ${(outBytes.length / 1024 / 1024).toStringAsFixed(2)} MB ($outExt)',
      );

      return compressedFile.path;
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      // On failure, fall back to the original file
      return imagePath;
    }
  }

  /// Target dimensions per image type.
  (int, int) _getTargetDimensions(ImageType imageType, img.Image image) {
    switch (imageType) {
      case ImageType.avatar:
      case ImageType.company:
        return (512, 512); // Square, avatar-style
      case ImageType.chat:
        // Keep aspect ratio, max 1024px on the longest side
        final aspectRatio = image.width / image.height;
        if (aspectRatio > 1) {
          return (1024, (1024 / aspectRatio).round());
        } else {
          return ((1024 * aspectRatio).round(), 1024);
        }
      case ImageType.announcement:
        // Keep aspect ratio, max 1200px on the longest side
        final aspectRatio = image.width / image.height;
        if (aspectRatio > 1) {
          return (1200, (1200 / aspectRatio).round());
        } else {
          return ((1200 * aspectRatio).round(), 1200);
        }
    }
  }

  /// Removes leftover temporary files created by compression.
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

      debugPrint('🧹 Temporary files cleaned up');
    } catch (e) {
      debugPrint('⚠️ Error cleaning up temporary files: $e');
    }
  }
}
