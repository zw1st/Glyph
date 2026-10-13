abstract interface class OcrService {
  Future<String> recognizeText({required String imagePath});
}
