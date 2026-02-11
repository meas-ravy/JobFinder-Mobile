import 'dart:io';
import 'package:dio/dio.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/recruiter/data/models/cloudinary_signature_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CloudinaryService {
  final Dio _authenticatedDio;
  final Dio _publicDio = Dio();

  CloudinaryService(this._authenticatedDio);

  /// Step 1: Get signature from backend
  Future<CloudinarySignatureModel> getUploadSignature(String imageType) async {
    try {
      final response = await _authenticatedDio.post(
        ApiEnpoint.getUploadSignature,
        data: {'imageType': imageType},
      );

      return CloudinarySignatureModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to get upload signature',
      );
    }
  }

  /// Step 2: Upload physical file to Cloudinary
  Future<String> uploadToCloudinary({
    required File file,
    required CloudinarySignatureModel signatureData,
  }) async {
    try {
      final String uploadUrl =
          'https://api.cloudinary.com/v1_1/${signatureData.cloudName}/image/upload';

      final Map<String, dynamic> params = {
        'timestamp': signatureData.timestamp.toString(),
        'api_key': signatureData.apiKey,
        'signature': signatureData.signature,
        'folder': signatureData.folder,
        'transformation': signatureData.transformation,
      };

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        ...params,
      });

      final response = await _publicDio.post(uploadUrl, data: formData);

      if (response.statusCode == 200) {
        return response.data['secure_url'] as String;
      } else {
        throw Exception('Cloudinary upload failed');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error']?['message'] ?? 'Cloudinary upload failed',
      );
    }
  }

  /// Combined method for convenience
  Future<String> uploadImage(File file, String imageType) async {
    final signature = await getUploadSignature(imageType);
    return await uploadToCloudinary(file: file, signatureData: signature);
  }
}

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);
  return CloudinaryService(dio);
});
