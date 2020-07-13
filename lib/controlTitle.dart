import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/models.dart';
import 'package:sudoku/sudokuMath.dart';
import 'package:fradio/fradio.dart';
import 'database.dart';

class ControlTitle extends StatelessWidget {
  BuildContext _ctx;
  int _level;
  SudokuDataModel _model;
  SudokuControlModel _control;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Consumer2<SudokuDataModel, SudokuControlModel>(
        builder: (_, m, c, __) {
          _level = c.groupValue;
          _model = m;
          _control = c;

          WidgetsBinding.instance.addPostFrameCallback((_) => _checkSuccess());
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _groupLevelRadio(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _startButton(),
                  Container( width: 110, height: 1.5, color: Colors.white,),
                  _noteButton(),
                ],
              )
            ],
          );
        }
    );
  }

  Widget _noteButton() {
    var style = _control.isNoteMode ?
      Theme.of(_ctx).textTheme.headline5.copyWith(color: Colors.pinkAccent, fontWeight: FontWeight.w800) :
      Theme.of(_ctx).textTheme.headline5.copyWith(color: Colors.black45);
    return CupertinoButton(
      child: Text("NoteMode", style: style,),
      onPressed: () { _control.setNoteMode(); }
    );
  }

  Widget _startButton() {
    return CupertinoButton(
//      child: Text(, style: TextStyle(fontFamily: 'Roboto', fontSize: 44),),
      child: Text("Start", style: Theme.of(_ctx).textTheme.headline4.copyWith(color: Colors.indigoAccent)),
      onPressed: _startOnPress,
    );
  }

  Widget _groupLevelRadio() {
    return Row(
      children: [
        _levelRadio(0),
        _levelRadio(1),
        _levelRadio(2),
        _levelRadio(3),
        _levelRadio(4),
      ],
    );
  }

  Widget _levelRadio(int level) {
    return Column(
      children: [
        Text(SudokuLevel[level], style: Theme.of(_ctx).textTheme.headline6,),
        FRadio(
          width: 80,
          height: 80,
          value: level,
          groupValue: _control.groupValue,
          onChanged: (v) {
            print("level $v");
            _control.setGroupValue(v);
          },
          child: Image.asset("assets/emoji_0.png", width: 50),
          hoverChild: Image.asset("assets/emoji_1.png", width: 50),
          selectedChild: Image.asset("assets/emoji_2.png", width: 50),
          hasSpace: false,
          toggleable: true,
          selectedColor: Color(0xffffc900),
          border: 1.5,
        )
      ],
    );
  }

  void _startOnPress() async {
    _loadingDialog();
    print("loading..");

//    var initData = await getWebData(_level);

    bool isErr = false;
    String errMsg;

    try {
       Map d = await MyDB().getExamination(_level);
       if (d == null) {
         _nextLevel();
         return;
       }

       String str = d["examination"] as String;
       print("Start $_level: ${d.toString()}, $str");

       List<int> list = [];
       for (var i=0; i<81; i++) { list.add(int.parse(str[i])); }
       _model.initData(list);
       _model.examinationID = d["id"] as int;
    } catch(e) {
      isErr = true;
      errMsg = e.toString();
    } finally {
      Navigator.of(_ctx, rootNavigator: true).pop();
    }

    if (isErr) {
      _loadingError(errMsg);
    }

  }

  Widget _loadingDialog() {
    showDialog(
      context: _ctx,
      useRootNavigator: false,
      builder: (context) =>  CupertinoActivityIndicator( radius: 30.0, ),
    );
  }

  Widget _loadingError(String errMsg) {
    showCupertinoDialog<int>(context: _ctx, builder: (ctx){
      return CupertinoAlertDialog(
        title: Text("Error", style: TextStyle(color: Colors.red)),
        //content: Text("Can't get data from http://cn.sudokupuzzle.org/."),
        content: Text(errMsg, style: TextStyle(color: Colors.red)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Retry"),
            onPressed: (){
              Navigator.pop(ctx,1);
              _startOnPress();
            },
          ),
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: (){ Navigator.pop(ctx,2); },
          )
        ],);
    });
  }

  Widget _nextLevel() {
    showCupertinoDialog<int>(context: _ctx, builder: (ctx){
      return CupertinoAlertDialog(
        title: Text("All complete"),
        content: Text("This level is all complete, please change one level."),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: (){ Navigator.pop(ctx); },
          )
        ],);
    });
  }

  void _checkSuccess() {
    if (!_model.success) {
      return;
    }

    //修改题目状态为完成
    MyDB().setOver( _model.examinationID, DateTime.now().millisecondsSinceEpoch );

    showCupertinoDialog<int>(context: _ctx, builder: (ctx){
      return CupertinoAlertDialog(
        title: Row(children: [
          Icon(Icons.toys, color: Colors.green, size: 20,),
          SizedBox(width: 5),
          Text("Success"),
        ],),
        content: Text("Gooooooooood job, you did it."),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Continue"),
            onPressed: (){
              Navigator.pop(ctx,1);
            },
          ),
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: (){ Navigator.pop(ctx,2); },
          )
        ],);
    });
  }
}
