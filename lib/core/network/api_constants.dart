import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static  String baseUrl = '${dotenv.env['URL_SERVICE']}/api/v1';


  // Timeout limits
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;
}
