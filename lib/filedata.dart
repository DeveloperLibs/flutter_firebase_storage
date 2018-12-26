import 'package:firebase_database/firebase_database.dart';

class FileData {

  String _id;
  String _name;
  String _file;


  FileData(this._id,this._name, this._file);

  String get name => _name;

  String get picFile => _file;

  String get id => _id;

  FileData.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _name = snapshot.value['name'];
    _file = snapshot.value['image'];
  }
}
