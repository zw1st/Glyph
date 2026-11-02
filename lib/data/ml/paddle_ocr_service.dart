import 'dart:io';

import 'package:flutter_paddle_ocr/flutter_paddle_ocr.dart';

import 'ocr_service.dart';

class PaddleOcrService implements OcrService {
  PaddleOcrService({
    required String detectionModelPath,
    required String recognitionModelPath,
    required String dictionaryPath,
  }) : _detectionModelPath = detectionModelPath,
       _recognitionModelPath = recognitionModelPath,
       _dictionaryPath = dictionaryPath;

  final String _detectionModelPath;
  final String _recognitionModelPath;
  final String _dictionaryPath;

  PaddleOcr? _ocr;
  Future<PaddleOcr>? _initialization;

  Future<PaddleOcr> _getOcr() {
    final existing = _ocr;
    if (existing != null) {
      return Future.value(existing);
    }

    return _initialization ??= _initialize();
  }

  Future<PaddleOcr> _initialize() async {
    try {
      final ocr = await PaddleOcr.create(
        source: ModelSource.filePaths(
          det: _detectionModelPath,
          rec: _recognitionModelPath,
          dict: _dictionaryPath,
        ),
      );

      _ocr = ocr;
      return ocr;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  @override
  Future<String> recognizeText({required String imagePath}) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final ocr = await _getOcr();

    final results = await ocr.recognize(imageBytes, runClassification: true);

    return results
        .map((result) => result.text.trim())
        .where((text) => text.isNotEmpty)
        .join('\n');
  }

  Future<void> dispose() async {
    final ocr = _ocr;
    _ocr = null;
    _initialization = null;

    await ocr?.dispose();
  }
}
