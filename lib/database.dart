import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class MyDB {
  String _appDocPath;
  String _appTmpPath;
  String _file;
  Database _db;

  String get file => _file;

  final String _name = "sudoku.db";

  // 工厂模式
  factory MyDB() =>_getInstance();
  static MyDB get instance => _getInstance();
  static MyDB _instance;

  MyDB._internal() {}

  static MyDB _getInstance() {
    if (_instance == null) {
      _instance = new MyDB._internal();
    }
    return _instance;
  }

  init() async {
    var appDocDir = await getApplicationDocumentsDirectory();
    var appTmpDir = await getTemporaryDirectory();
    _appDocPath = appDocDir.path;
    _appTmpPath = appTmpDir.path;
//    _file = "$_appDocPath/.$_name";
    _file = p.join(_appDocPath, _name);

    print("++++++++++++$_appTmpPath $_appDocPath $_file");


    await Directory(_appDocPath).create(recursive: true).then((Directory directory) {
      print(directory.path);
    });

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(_file) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load("assets/$_name");
      List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await File(_file).writeAsBytes(bytes);
    }

    _db = await openDatabase(_file);
  }

  Future<Map> getExamination(int level) async {
    List<Map> list =  await _db.rawQuery('SELECT * FROM sudoku WHERE level=$level AND over_time==0 LIMIT 1;');
    return list.length == 1 ? list[0] : null;
  }

  Future<int> setOver(int id, int t) async {
    int res = await _db.rawUpdate('UPDATE sudoku SET over_time=$t WHERE id=$id;');
    print("update $id: $res");
    return res;
  }

  String toString() {
    return "dbfile: $_file";
  }
}