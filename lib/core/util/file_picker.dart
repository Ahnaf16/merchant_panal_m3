import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'failure.dart';

final filePickerProvider = Provider<FilePickerRepo>((ref) => FilePickerRepo());

class FilePickerRepo {
  final picker = FilePicker.platform;

  FutureEither<PlatformFile> pickFile({
    FileType type = FileType.custom,
    List<String>? allowedExtensions,
  }) async {
    FilePickerResult? result = await picker.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
    );

    try {
      if (result == null) {
        return left(const Failure('No img selected'));
      }

      return right(result.files.single);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<PlatformFile> pickImage() async {
    FilePickerResult? result = await picker.pickFiles(type: FileType.image);

    try {
      if (result == null) {
        return left(const Failure('No img selected'));
      }

      return right(result.files.single);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<PlatformFile>> pickMultipleImage() async {
    FilePickerResult? result =
        await picker.pickFiles(type: FileType.image, allowMultiple: true);

    try {
      if (result == null) {
        return left(const Failure('No img selected'));
      }

      List<PlatformFile> files = result.files;
      return right(files);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
