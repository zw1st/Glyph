import '../../domain/enum/ocr_engine.dart';
import 'ocr_service.dart';

class OcrServiceFactory {
  OcrServiceFactory({required OcrService mlKit, required OcrService tesseract})
    : _mlKit = mlKit,
      _tesseract = tesseract;

  final OcrService _mlKit;
  final OcrService _tesseract;

  OcrService get(OcrEngine type) {
    return switch (type) {
      OcrEngine.mlKit => _mlKit,
      OcrEngine.tesseract => _tesseract,
    };
  }
}
