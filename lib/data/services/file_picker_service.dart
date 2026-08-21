import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Fine wrapper around the static FilePicker API so it can be mocked in tests.
abstract class FilePickerService {
  Future<String?> pickFile({List<String>? allowedExtensions, String? dialogTitle});

  Future<Uri?> saveFile({required String dialogTitle, required String fileName, required String content});
}

class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<String?> pickFile({List<String>? allowedExtensions, String? dialogTitle}) async {
    final PlatformFile? inputFile = await FilePicker.pickFile(
      dialogTitle: dialogTitle,
      allowedExtensions: allowedExtensions,
    );
    if (inputFile == null) return null;
    return utf8.decode(await inputFile.readAsBytes());
  }

  @override
  Future<Uri?> saveFile({required String dialogTitle, required String fileName, required String content}) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: utf8.encode(content),
      type: FileType.custom,
    );
  }
}
