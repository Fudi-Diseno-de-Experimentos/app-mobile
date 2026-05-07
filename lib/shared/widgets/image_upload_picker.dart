import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/network/cloudinary_service.dart';

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
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Se requiere permiso de cámara')),
          );
        }
        return;
      }
    } else {
      // Handle gallery permissions for Android 13+ (API 33)
      if (Platform.isAndroid) {
        // On Android 13+, we need to check for photos permission
        // Permission.photos is for READ_MEDIA_IMAGES
        var status = await Permission.photos.request();
        
        // On Android 14+ (API 34), we might have limited access
        if (!status.isGranted && !status.isLimited) {
          // Fallback for older Android versions
          var storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Se requiere permiso de galería')),
              );
            }
            return;
          }
        }
      } else {
        // iOS
        var status = await Permission.photos.request();
        if (!status.isGranted && !status.isLimited) return;
      }
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _isUploading = true;
        // Mostramos una previsualización local antes de subir
        _currentImageUrl = image.path; 
      });

      final url = await _cloudinaryService.uploadImage(image.path);

      setState(() {
        _isUploading = false;
        if (url != null) {
          _currentImageUrl = url;
          widget.onImageUploaded(url);
        } else {
          // Si falla la subida, limpiamos o mostramos error
          _currentImageUrl = widget.initialImageUrl;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al subir la imagen a la nube')),
            );
          }
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
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_currentImageUrl != null)
                        Opacity(
                          opacity: 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _currentImageUrl!.startsWith('http')
                                ? Image.network(_currentImageUrl!, fit: BoxFit.cover, width: double.infinity)
                                : Image.file(File(_currentImageUrl!), fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                      const CircularProgressIndicator(),
                    ],
                  )
                : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _currentImageUrl!.startsWith('http')
                            ? Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 50),
                              )
                            : Image.file(
                                File(_currentImageUrl!),
                                fit: BoxFit.cover,
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
