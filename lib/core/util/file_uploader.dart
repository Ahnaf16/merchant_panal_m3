import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gngm/core/core.dart';

final fileUploaderProvider = Provider<FileUploader>((ref) => FileUploader());

class FileUploader {
  final _storage = FirebaseStorage.instance;
  FutureEither<String> uploadImage({
    required String storagePath,
    required PlatformFile imagePath,
    required String fileName,
  }) async {
    await Toaster.show('Uploading image');

    final reference =
        _storage.ref().child('$storagePath/$fileName').child('$fileName.jpeg');

    final Uint8List bytes;

    if (kIsWeb) {
      bytes = imagePath.bytes!;
    } else {
      bytes = await File(imagePath.path!).readAsBytes();
    }

    try {
      await reference.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await reference.getDownloadURL();
      Toaster.show('Image Uploaded');
      return right(url);
    } on FirebaseException catch (e) {
      log(e.toString());
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<List<String>> uploadMultiImage({
    required String fileName,
    required List<PlatformFile> imgPaths,
    required String storagePath,
    int startIndex = 0,
  }) async {
    List<String> urls = [];
    int inx = startIndex;
    try {
      for (final path in imgPaths) {
        Toaster.show('Uploading ${imgPaths.length} images');

        final reference = _storage
            .ref()
            .child('$storagePath/$fileName')
            .child('${fileName}_$inx.jpeg');
        inx++;
        final Uint8List bytes;

        if (kIsWeb) {
          bytes = path.bytes!;
        } else {
          bytes = await File(path.path!).readAsBytes();
        }
        await reference.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await reference.getDownloadURL();

        urls.add(url);
        Toaster.remove();
      }
      Toaster.show('All Image Uploaded');
      return right(urls);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<String> uploadFile({
    required String storagePath,
    required PlatformFile file,
    required String fileName,
    required String extension,
  }) async {
    await Toaster.show('Uploading File');

    final reference = _storage
        .ref()
        .child('$storagePath/$fileName')
        .child('$fileName.$extension');

    final Uint8List bytes;

    if (kIsWeb) {
      bytes = file.bytes!;
    } else {
      bytes = await File(file.path!).readAsBytes();
    }

    try {
      await reference.putData(bytes);

      final url = await reference.getDownloadURL();
      Toaster.show('File Uploaded');
      return right(url);
    } on FirebaseException catch (e) {
      log(e.toString());
      return left(Failure.fromFirebase(e));
    }
  }

  FutureEither<bool> deleteImage({
    required String storagePath,
    required String fileName,
  }) async {
    try {
      final reference = _storage.ref().child('$storagePath/$fileName');
      final itemList = await reference.list();

      Toaster.show('${itemList.items.length} items to delete');
      for (final item in itemList.items) {
        await item.delete();
      }
      Toaster.show('Image Deleted');
      return right(true);
    } on FirebaseException catch (e) {
      return left(Failure.fromFirebase(e));
    }
  }
}
