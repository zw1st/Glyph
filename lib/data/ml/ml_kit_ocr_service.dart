import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_service.dart';

class MlKitOcrService implements OcrService {
  final TextRecognizer _recognizer;

  MlKitOcrService()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText({required String imagePath}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);

    return result.text;
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
