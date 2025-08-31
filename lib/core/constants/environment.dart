import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initPrdEnvironment() async {
    await dotenv.load(fileName: '.env.production');
  }

  static initLocalEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl =
      dotenv.env['API_URL'] ?? 'No está configurado el API_URL';

  static String apiKey =
      dotenv.env['API_KEY'] ?? 'No está configurado el API_KEY';

  static String appId = dotenv.env['APP_ID'] ?? 'No está configurado el APP_ID';

  static String messagingSenderId =
      dotenv.env['MESSAGING_SENDER_ID'] ??
      'No está configurado el MESSAGING_SENDER_ID';

  static String projectId =
      dotenv.env['PROJECT_ID'] ?? 'No está configurado el PROJECT_ID';

  static String storageBucket =
      dotenv.env['STORAGE_BUCKET'] ?? 'No está configurado el STORAGE_BUCKET';
}
