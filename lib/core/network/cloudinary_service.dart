import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  final Dio _dio = Dio();

  Future<String?> uploadImage(File file) async {
    try {
      final cloudName = dotenv.env['Cloud name']?.trim();
      final apiKey = dotenv.env['Api Key']?.trim();
      final apiSecret = dotenv.env['API Secret']?.trim();

      if (cloudName == null || apiKey == null) {
        throw Exception('Cloudinary configuration missing');
      }

      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
        "upload_preset": "ml_default", // You might need to set this up in Cloudinary
        "api_key": apiKey,
      });

      // Note: For signed uploads you need more logic, 
      // but usually for mobile apps ml_default (unsigned) is easier to start with.
      // If the user didn't specify a preset, this might fail unless configured in Cloudinary.
      
      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['secure_url'];
      }
      return null;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }
}
