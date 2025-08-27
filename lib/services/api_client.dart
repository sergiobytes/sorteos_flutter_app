import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:sorteos_app/config/constants/environment.dart';

class PurgeResult {
  final int deletedParticipants;
  final int deletedPhotos;
  PurgeResult({required this.deletedParticipants, required this.deletedPhotos});
}

class ApiClient {
  static String apiBase = Environment.apiUrl;
  final http.Client _http = http.Client();
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getUploadSignature() async {
    final url = Uri.parse('$apiBase/sign-upload');
    final resp = await _http.post(url);

    if (resp.statusCode != 200) {
      throw Exception('Error firmando upload');
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadToCloudinary({
    required Map<String, dynamic> signPayload,
    required File imageFile,
  }) async {
    final cloudName = signPayload['cloudName'];
    final apiKey = signPayload['apiKey'].toString();
    final timestamp = signPayload['timestamp'].toString();
    final signature = signPayload['signature'].toString();
    final folder = signPayload['folder'].toString();
    final type = signPayload['type'].toString();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
      'api_key': apiKey,
      'timestamp': timestamp,
      'signature': signature,
      'folder': folder,
      'type': type,
    });

    final url = 'http://api.cloudinary.com/v1_1/$cloudName/image/upload';
    final resp = await _dio.post(url, data: formData);

    if (resp.statusCode != 200) {
      throw Exception('Fallo al subir a Cloudinary');
    }

    final data = resp.data as Map<String, dynamic>;

    return {
      'public_id': data['public_id'],
      'version': data['version']?.toString(),
    };
  }

  Future<void> createParticipant({
    required String name,
    required String walletNumber,
    required String phone,
    required String photoPublicId,
    String? photoVersion,
  }) async {
    final url = Uri.parse('$apiBase/participants');

    final body = jsonEncode({
      'name': name,
      'walletNumber': walletNumber,
      'phone': phone,
      'photoPublicId': photoPublicId,
      'photoVersion': photoVersion,
    });

    final resp = await _http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 201) {
      throw Exception('Error creando participante');
    }
  }

  Future<File> downloadZip({
    required String idToken,
    required String savePath,
  }) async {
    final url = '$apiBase/admin/export';

    final resp = await _dio.get(
      url,
      options: Options(
        headers: {'Authorization': 'Bearer $idToken'},
        responseType: ResponseType.stream,
      ),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error descargando archivo ZIP');
    }

    final file = File(savePath);
    final sink = file.openWrite();
    await for (final chunk in resp.data.stream) {
      sink.add(chunk);
    }
    await sink.close();

    return file;
  }

  Future<PurgeResult> purgeAll({
    required String idToken,
    bool deletePhotos = true, // cámbialo si no quieres borrar fotos
  }) async {
    final url = '$apiBase/admin/purge';

    final resp = await _dio.post(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'X-Confirm-Purge': 'yes', // confirmación obligatoria del backend
        },
      ),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error purgando base de datos (${resp.statusCode})');
    }

    final data = resp.data as Map<String, dynamic>;
    return PurgeResult(
      deletedParticipants: (data['deletedParticipants'] ?? 0) as int,
      deletedPhotos: (data['deletedPhotos'] ?? 0) as int,
    );
  }
}
