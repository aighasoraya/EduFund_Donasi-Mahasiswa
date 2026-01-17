import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SteganographyService {
  static const String _separator = "###EDU_SECURE###";
  static Future<File> sembunyikanData(File originalImage, String userId) async {
    try {
      Uint8List imageBytes = await originalImage.readAsBytes();
      String timestamp = DateTime.now().toIso8601String();
      String secretMessage = "$_separator|$userId|$timestamp";
      List<int> messageBytes = utf8.encode(secretMessage);
      List<int> stegoBytes = [...imageBytes, ...messageBytes];
      final directory = await getTemporaryDirectory();
      final String fileName = 'stego_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File stegoImage = File('${directory.path}/$fileName');

      await stegoImage.writeAsBytes(stegoBytes);

      if (kDebugMode) {
        print("============================================");
        print("    LOG SISTEM KEAMANAN (STEGANOGRAFI)      ");
        print("============================================");
        print("File Target : ${originalImage.path.split('/').last}");
        print("Injection   : EOF (End of File)");
        print("Payload     : $secretMessage");
        print("Size Asli   : ${imageBytes.length} bytes");
        print("Size Baru   : ${stegoBytes.length} bytes");
        print("Status      : SECURED & READY FOR UPLOAD");
        print("============================================");
      }

      return stegoImage;
    } catch (e) {
      if (kDebugMode) print("❌ Error Steganografi: $e");
      return originalImage;
    }
  }

  static Future<String?> bacaDataTersembunyi(File imageFile) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      String content = utf8.decode(bytes, allowMalformed: true);

      if (content.contains(_separator)) {
        return content.split(_separator).last;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}