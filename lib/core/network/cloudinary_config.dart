import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Cloudinary para subida de imágenes
class CloudinaryConfig {
  // 🔐 Credenciales de Cloudinary (usar variables de entorno)
  static String get cloudName => dotenv.env['CLOUD_NAME'] ?? "dpprgycup";
  static String get apiKey => dotenv.env['API_KEY'] ?? "454726488133594";
  static String get apiSecret => dotenv.env['API_SECRET'] ?? "G1TYaQ8qxvFzqnO5pogYhr-nFFQ";

  // 📁 Upload Presets (configurar en dashboard de Cloudinary como unsigned)
  static const String avatarUploadPreset = "centralis_avatars";
  static const String chatUploadPreset = "centralis_chat";
  static const String announcementUploadPreset = "centralis_announcements";

  // 📂 Carpetas organizadas
  static const String avatarFolder = "avatars";
  static const String chatFolder = "chat";
  static const String announcementFolder = "announcements";

  // 🖼️ Transformaciones automáticas
  static const String avatarTransformation = "c_fill,w_200,h_200,r_max,q_auto";
  static const String chatTransformation = "c_fit,w_800,h_600,q_auto";
  static const String announcementTransformation = "c_fit,w_1200,h_800,q_auto";

  // 📏 Tamaños máximos en bytes
  static const int avatarMaxSize = 1024 * 1024;         // 1MB
  static const int chatMaxSize = 5 * 1024 * 1024;       // 5MB
  static const int announcementMaxSize = 10 * 1024 * 1024; // 10MB

  // 🎯 Configuración por tipo de imagen
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
    }
  }
}

/// Tipos de imagen soportados
enum ImageType {
  avatar,
  chat,
  announcement
}

/// Configuración específica por tipo de imagen
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
