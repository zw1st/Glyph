import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

import 'ocr_service.dart';

class TesseractOcrService implements OcrService {
  @override
  Future<String> recognizeText({required String imagePath}) async {
    final config = OCRConfig(
      language: 'rus+eng',
      engine: OCREngine.tesseract,
      options: {
        'tessedit_pageseg_mode': '6',
        'tessedit_ocr_engine_mode': '1',
        'preserve_interword_spaces': '1',
      },
    );

    return TesseractOcr.extractText(imagePath, config: config);
  }
}
