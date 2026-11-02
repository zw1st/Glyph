import '../../domain/enum/ocr_engine.dart';
import 'ocr_service.dart';

class OcrServiceFactory {
  OcrServiceFactory({
    required OcrService mlKit,
    required OcrService tesseract,
    required OcrService paddle,
  }) : _mlKit = mlKit,
       _tesseract = tesseract,
       _paddle = paddle;

  final OcrService _mlKit;
  final OcrService _tesseract;
  final OcrService _paddle;

  OcrService get(OcrEngine type) {
    return switch (type) {
      OcrEngine.mlKit => _mlKit,
      OcrEngine.tesseract => _tesseract,
      OcrEngine.paddle => _paddle,
    };
  }
}
