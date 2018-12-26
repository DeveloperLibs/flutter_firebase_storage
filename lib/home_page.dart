import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_storage/filedata.dart';
import 'package:flutter_firebase_storage/firebase_database_util.dart';
import 'package:flutter_firebase_storage/firebase_storage_util.dart';
import 'package:image_picker_ui/image_picker_handler.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with ImagePickerListener, TickerProviderStateMixin {
  List<FileData> files = new List();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  FirebaseDatabaseUtil firebaseDatabase;
  FirebaseStorageUtil _firebaseStorageUtil;
  AnimationController _controller;
  ImagePickerHandler imagePicker;

  @override
  void initState() {
    super.initState();
    firebaseDatabase = FirebaseDatabaseUtil();
    _firebaseStorageUtil = FirebaseStorageUtil();
    firebaseDatabase.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();
    firebaseDatabase.ref().onChildAdded.listen(_updateList);
  }

  @override
  Widget build(BuildContext context) {
    Widget uploadProgress = new SizedBox(
      width: 0.0,
      height: 0.0,
    );
    _tasks.forEach((StorageUploadTask task) {
      uploadProgress = UploadProgressWidget(
        task: task,
        firebaseStorage: firebaseDatabase,
      );
    });
    _tasks.clear();
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          "Firebase Storage",
          style: new TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          new Padding(
            padding: EdgeInsets.all(10.0),
            child: uploadProgress,
          )
        ],
      ),
      body: new GridView.count(
        primary: true,
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        children: List.generate(files.length, (index) {
          return getStructuredGridCell(files[index]);
        }),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => imagePicker.showDialog(context),
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  Card getStructuredGridCell(FileData file) {
    return new Card(
      child: Stack(
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          Center(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: file.picFile,
            ),
          ),
        ],
      ),
    );
  }

  _updateList(Event event) {
    setState(() {
      files.add(new FileData.fromSnapshot(event.snapshot));
    });
  }

  @override
  userImage(File _image) {
    setState(() {
      _tasks.add(_firebaseStorageUtil.uploadFile(_image));
    });
    return null;
  }
}

class UploadProgressWidget extends StatelessWidget {
  final StorageUploadTask task;

  final FirebaseDatabaseUtil firebaseStorage;

  const UploadProgressWidget({Key key, this.task, this.firebaseStorage})
      : super(key: key);

  Future<String> get status async {
    String result;
    if (task.isComplete) {
      if (task.isSuccessful) {
        String url = await task.lastSnapshot.ref.getDownloadURL();
        var file = FileData(task.lastSnapshot.ref.toString(),
            task.lastSnapshot.storageMetadata.name, url);
        result = 'Complete' + task.lastSnapshot.ref.toString();
        firebaseStorage.addUser(file);
      } else if (task.isCanceled) {
        result = 'Canceled';
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        print('$status:uploading');
        return Dismissible(
          key: Key(task.hashCode.toString()),
          child: new Row(
            children: <Widget>[new CircularProgressIndicator()],
          ),
        );
      },
    );
  }
}
