import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseStorageUtil {
  static final FirebaseStorageUtil _instance =
      new FirebaseStorageUtil.internal();

  FirebaseStorageUtil.internal();

  factory FirebaseStorageUtil() {
    return _instance;
  }

  StorageUploadTask uploadFile(File file) {
    final StorageReference ref =
        new FirebaseStorage().ref().child('Files').child(basename(file.path));

    final StorageUploadTask uploadTask = ref.putFile(file);

    return uploadTask;
  }
}
