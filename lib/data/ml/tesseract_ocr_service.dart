import 'package:flutter_tesseract_ocr/android_ios.dart';

import 'ocr_service.dart';

class TesseractOcrService implements OcrService {
  @override
  Future<String> recognizeText({required String imagePath}) async {
    final config = {'psm': '', 'preserve_interword_spaces': '1'};

    return FlutterTesseractOcr.extractText(
      imagePath,
      args: config,
      language: 'eng',
    );
  }
}
