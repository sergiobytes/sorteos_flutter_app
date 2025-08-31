import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<http.Response> get(String path) async {
    return await http.get(Uri.parse('$baseUrl/$path'));
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
      body: body,
    );
  }
}
