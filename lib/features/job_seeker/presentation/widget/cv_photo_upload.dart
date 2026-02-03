import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class CvPhotoUpload extends StatefulWidget {
  final Function(String path)? onImagePicked;
  const CvPhotoUpload({super.key, this.onImagePicked});

  @override
  State<CvPhotoUpload> createState() => _CvPhotoUploadState();
}

class _CvPhotoUploadState extends State<CvPhotoUpload> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;

  void _showImageDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Option for Upload Photo',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: AppSvgIcon(
                  assetName: AppIcon.camera,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: AppSvgIcon(
                  assetName: AppIcon.image,
                  color: colorScheme.onSurface,
                ),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      maxHeight: 512,
      maxWidth: 512,
    );
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
      widget.onImagePicked?.call(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageDialog(context),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      File(_profileImage!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 60,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showImageDialog(context),
          icon: AppSvgIcon(
            assetName: _profileImage != null ? AppIcon.edit : AppIcon.camera,
            size: 26,
            color: colorScheme.primary,
          ),
          label: Text(_profileImage != null ? 'Change Photo' : 'Upload Photo'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
