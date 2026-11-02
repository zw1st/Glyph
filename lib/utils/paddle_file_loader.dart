import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class PaddleModelFiles {
  const PaddleModelFiles({
    required this.det,
    required this.rec,
    required this.dict,
  });

  final String det, rec, dict;

  static const _assetDir = 'assets/ocr/paddle';
  static const _version = '9';

  static Future<PaddleModelFiles> prepare() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/paddle_ocr_v$_version');
    await dir.create(recursive: true);

    Future<String> copy(String name) async {
      final file = File('${dir.path}/$name');
      if (!await file.exists() || await file.length() == 0) {
        final data = await rootBundle.load('$_assetDir/$name');
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          flush: true,
        );
      }
      return file.path;
    }

    return PaddleModelFiles(
      det: await copy('det.onnx'),
      rec: await copy('rec_eslav.onnx'),
      dict: await copy('dict_eslav.txt'),
    );
  }
}
