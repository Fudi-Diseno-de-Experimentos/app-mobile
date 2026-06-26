import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudinary configuration for image uploads.
///
/// Uploads use unsigned presets, so only the cloud name is needed at runtime.
/// Never add API keys/secrets here: `.env` is bundled as a Flutter asset and
/// anything in it ships inside the APK/IPA.
class CloudinaryConfig {
  static String get cloudName =>
      dotenv.env['CLOUD_NAME'] ??
      (throw StateError('CLOUD_NAME is missing from .env'));

  // Upload presets (configured as unsigned in the Cloudinary dashboard)
  static const String avatarUploadPreset = 'centralis_avatars';
  static const String chatUploadPreset = 'centralis_chat';
  static const String announcementUploadPreset = 'centralis_announcements';

  // Folders
  static const String avatarFolder = 'avatars';
  static const String chatFolder = 'chat';
  static const String announcementFolder = 'announcements';
  static const String companyFolder = 'companies';

  // Automatic transformations
  static const String avatarTransformation = 'c_fill,w_200,h_200,r_max,q_auto';
  static const String chatTransformation = 'c_fit,w_800,h_600,q_auto';
  static const String announcementTransformation = 'c_fit,w_1200,h_800,q_auto';

  // Maximum sizes in bytes
  static const int avatarMaxSize = 1024 * 1024; // 1MB
  static const int chatMaxSize = 5 * 1024 * 1024; // 5MB
  static const int announcementMaxSize = 10 * 1024 * 1024; // 10MB

  static ImageConfig getConfigForType(ImageType type) {
    switch (type) {
      case ImageType.avatar:
        return const ImageConfig(
          uploadPreset: avatarUploadPreset,
          folder: avatarFolder,
          transformation: avatarTransformation,
          maxSize: avatarMaxSize,
          allowedFormats: ['jpg', 'png', 'webp'],
        );
      case ImageType.chat:
        return const ImageConfig(
          uploadPreset: chatUploadPreset,
          folder: chatFolder,
          transformation: chatTransformation,
          maxSize: chatMaxSize,
          allowedFormats: ['jpg', 'png', 'gif', 'webp'],
        );
      case ImageType.announcement:
        return const ImageConfig(
          uploadPreset: announcementUploadPreset,
          folder: announcementFolder,
          transformation: announcementTransformation,
          maxSize: announcementMaxSize,
          allowedFormats: ['jpg', 'png', 'webp'],
        );
      case ImageType.company:
        // Reuses the announcement unsigned preset (no dedicated preset exists
        // in the Cloudinary dashboard yet) but stores logos in their own
        // folder with avatar-style sizing.
        return const ImageConfig(
          uploadPreset: announcementUploadPreset,
          folder: companyFolder,
          transformation: avatarTransformation,
          maxSize: avatarMaxSize,
          allowedFormats: ['jpg', 'png', 'webp'],
        );
    }
  }
}

/// Supported image types
enum ImageType {
  avatar,
  chat,
  announcement,
  company
}

/// Per-type image configuration
class ImageConfig {
  final String uploadPreset;
  final String folder;
  final String transformation;
  final int maxSize;
  final List<String> allowedFormats;

  const ImageConfig({
    required this.uploadPreset,
    required this.folder,
    required this.transformation,
    required this.maxSize,
    required this.allowedFormats,
  });
}
