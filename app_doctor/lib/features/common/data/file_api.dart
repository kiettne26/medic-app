import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../../../core/network/dio_provider.dart';

class FileApi {
  final Dio _dio;

  FileApi(this._dio);

  Future<String?> uploadFile(XFile file) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: file.name,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      });

      // The backend endpoint is /users/upload.
      // Need to check if it's handled by Gateway.
      // In application.yml: Path=/api/users/** -> user-service
      // So path should be /api/users/upload
      final response = await _dio.post(
        '/api/users/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data']['url'];
      }
      return null;
    } catch (e) {
      print('Upload Error: $e');
      if (e is DioException) {
        print('DioError: ${e.response?.statusCode} ${e.response?.data}');
      }
      rethrow;
    }
  }
}

final fileApiProvider = Provider<FileApi>((ref) {
  final dio = ref.watch(dioProvider);
  return FileApi(dio);
});
