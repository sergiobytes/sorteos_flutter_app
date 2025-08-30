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

class Participant {
  final String name;
  final String walletNumber;
  Participant({required this.name, required this.walletNumber});

  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
    name: j['name'] as String,
    walletNumber: ['walletNumber'] as String,
  );
}

class ApiClient {
  Future<Map<String, dynamic>> deleteCloudinaryImage({
    required Map<String, dynamic> signPayload,
    required String publicId,
  }) async {
    final cloudName = signPayload['cloudName'];
    final apiKey = signPayload['apiKey'].toString();
    final timestamp = signPayload['timestamp'].toString();
    final signature = signPayload['signature'].toString();
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';

    final formData = FormData.fromMap({
      'public_id': publicId,
      'api_key': apiKey,
      'timestamp': timestamp,
      'signature': signature,
    });

    final resp = await _dio.post(url, data: formData);
    if (resp.statusCode != 200) {
      throw Exception('Error borrando imagen de Cloudinary');
    }
    return resp.data as Map<String, dynamic>;
  }

  static String apiBase = Environment.apiUrl;
  final http.Client _http = http.Client();
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getUploadSignature(String walletNumber) async {
    final url = Uri.parse('$apiBase/sign-upload');
    final resp = await _http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'walletNumber': walletNumber}),
    );

    if (resp.statusCode == 409) {
      throw Exception('Número de cartera ya registrado');
    }

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

  Future<void> markPaidByWallet({
    required String idToken,
    required String walletNumber,
    required String adminEmail,
  }) async {
    final normalized = padWallet(walletNumber);

    if (normalized.isEmpty) throw Exception('Cartera inválida. Usa 001-840');

    final resp = await _dio.put(
      '$apiBase/admin/mark-paid',
      data: {'walletNumber': normalized, 'adminEmail': adminEmail},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Error marcando como pagado (${resp.statusCode})');
    }
  }

  String padWallet(String w) {
    final digits = w.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final n = int.tryParse(digits) ?? 0;
    if (n < 1 || n > 840) return '';
    return n.toString().padLeft(3, '0');
  }

  Future<List<Participant>> fetchUnpaid({
    required String idToken,
    String query = "",
  }) async {
    final resp = await _dio.get(
      '$apiBase/admin/unpaid',
      queryParameters: {'q': query},
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error obteniendo no pagados (${resp.statusCode})');
    }
    final data = resp.data as List;
    return data
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
