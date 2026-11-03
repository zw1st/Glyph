import 'dart:io';

import 'package:flutter_paddle_ocr_v5/flutter_paddle_ocr.dart';
import 'package:glyph/utils/paddle_file_loader.dart';

import 'ocr_service.dart';

class PaddleOcrService implements OcrService {
  PaddleOcrService({required Future<PaddleModelFiles> Function() loadModels})
    : _loadModels = loadModels;

  final Future<PaddleModelFiles> Function() _loadModels;

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
      final files = await _loadModels();
      final ocr = await PaddleOcr.create(
        source: ModelSource.filePaths(
          det: files.det,
          rec: files.rec,
          dict: files.dict,
        ),
        useSpaceChar: true,
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

    final results = await ocr.recognize(
      imageBytes,
      runClassification: false,
      runDetection: true,
    );

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
