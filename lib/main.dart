import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'database.dart';
import 'sudoku.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
//        visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: FutureBuilder(
      future: _initMyDB(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error.toString()}", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red)),
          );
        } else if (snapshot.hasData) {
          print(snapshot.data);
          return SudokuSkeleton();
        }

        return Container(
          child: CupertinoActivityIndicator( radius: 30.0, )
        );
      }
    ));
  }
  /*
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
//        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SudokuSkeleton(),
    );
  }
   */

  Future<String> _initMyDB() async {
    await MyDB().init();
    return MyDB().toString();
  }
}

