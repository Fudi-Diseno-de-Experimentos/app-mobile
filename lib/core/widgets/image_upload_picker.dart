import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../network/cloudinary_service.dart';

class ImageUploadPicker extends StatefulWidget {
  final Function(String) onImageUploaded;
  final String? initialImageUrl;

  const ImageUploadPicker({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
  });

  @override
  State<ImageUploadPicker> createState() => _ImageUploadPickerState();
}

class _ImageUploadPickerState extends State<ImageUploadPicker> {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permissions
    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) return;
    } else {
      // For photos on newer Android versions, it might be different, 
      // but permission_handler handles basic cases.
      var status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      final url = await _cloudinaryService.uploadImage(File(image.path));

      setState(() {
        _isUploading = false;
        if (url != null) {
          _currentImageUrl = url;
          widget.onImageUploaded(url);
        }
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del Anuncio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _showPickerOptions,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca para subir una imagen',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
