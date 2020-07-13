import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/models.dart';
import 'package:sudoku/sudokuMath.dart';
import 'package:sudoku/controlTitle.dart';
import 'package:sudoku/versionInfo.dart';


class SudokuSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider<SudokuDataModel>( create: (_) => SudokuDataModel()),
          ChangeNotifierProvider<SudokuControlModel>( create: (_) => SudokuControlModel()),
        ],
        child: Container(
          color: Colors.black12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ControlTitle(),
              MySudoku(),
              VersionInfo(),
            ],
          ),
        ),
      ),
    );
  }
}


class MySudoku extends StatelessWidget {
  final double _borderWidth = 2.5;
  final Color _borderColor = Colors.blueGrey;
  final double _width = 600.0;
  final double _height = 600.0;
  final FocusNode _focusNode = FocusNode();

  BuildContext _ctx;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    FocusScope.of(context).requestFocus(_focusNode);

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _onKeyEvent,

      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: _borderColor,
          border: Border.all(color: _borderColor, width: _borderWidth),
        ),
        child: GridView.count(
          crossAxisSpacing: _borderWidth,
          mainAxisSpacing: _borderWidth,
          crossAxisCount: 3,
          children: _children(),
        ),
      )
    );
  }



  List<Widget> _children() {
    List<Widget> list = [];
    for (var i=0; i< 9; i++) {
      list.add( Sudoku(SudokuCoords(i)) );
    }
    return list;
  }

  void _onKeyEvent(RawKeyEvent event) {
//    print(event);
    if (event.runtimeType != RawKeyUpEvent) {
      return;
    }

    //获取0-9字符 (0 == Backspace)
    int i = 0;
    try {
      if (event.data.physicalKey.debugName != "Backspace") {
        i = int.parse(event.data.keyLabel);
      }
    } catch (e) {
      return;
    }

    print(i);

    //处理删除
    if (i == 0) {
      _ctx.read<SudokuDataModel>().doBackspace();
      return;
    }

    bool isNoteMode = _ctx.read<SudokuControlModel>().isNoteMode;
    print("KeyEvent isNoteMode: $isNoteMode");

    /*
    //笔记模式 删除
    if (isNoteMode &&  i == 0) {
      _ctx.read<SudokuDataModel>().removeNotes();
      return;
    }
     */

    //笔记模式 记录
    if (isNoteMode) {
      _ctx.read<SudokuDataModel>().setNotes(i);
      return;
    }

    //正常标记
    _ctx.read<SudokuDataModel>().setValue(i);
  }
}

class Sudoku extends StatelessWidget {
  List<Coords> _coordsList;
  Sudoku(this._coordsList);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        crossAxisCount: 3,
        children: _children(),
      ),
    );
  }

  List<Widget> _children() {
    return _coordsList.map((e) => SudokuCell(e)).toList();
  }
}

class SudokuCell extends StatelessWidget {
  final Coords _coords;

  SudokuCell(this._coords);

  BuildContext _ctx;
  SudokuDataModel _model;
  Cell _cell;

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Consumer<SudokuDataModel>(
        builder: (_, m, __) {
          _cell = m.getCell(_coords);

          var child = _cell.value > 0 ? _valueChild() : _notesChild();

//        print("build");
          return GestureDetector(
            onTapUp: (_) async {
              print("click:\n${_cell.toString()}");
              m.setSelected(_coords);
            },
            child:Container(
                  color: _cell.selected ? Colors.lightGreen[100] : Colors.white,
                  child: Center(
//                    child: Text("$value", style: textStyle),
                    child: child,
                  )
              ),
          );
        }
    );
  }

  Widget _valueChild() {
    var value = _cell.value;
    var isSameValue = _cell.sameValue;
    var isEdit = _cell.isEdit;
    var isError = _cell.isError;

    var textStyle = () {
      if (isError) {
        return Theme.of(_ctx).textTheme.headline3.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w600);
      }
      if (isSameValue) {
        return Theme.of(_ctx) .textTheme .headline3 .copyWith(color: Theme.of(_ctx) .colorScheme .primary);
      }
      if (isEdit) {
        return Theme.of(_ctx) .textTheme .headline4 .copyWith(color: Colors.black54);
      }
      return Theme.of(_ctx) .textTheme .headline4 .copyWith(color: Colors.black87, fontWeight: FontWeight.w600);
    }();

    return Text("$value", style: textStyle);
  }

  Widget _notesChild() {
    var notes = _cell.notes;
    if (notes.length == 0) {
      return Container();
    }

    var s = notes.join(",");
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(5),
      child: Text("$s", style: Theme.of(_ctx).textTheme.bodyText1.copyWith(color: Colors.green)),
    );
    return Wrap( children: notes.map((e) => Text("$e", style: Theme.of(_ctx).textTheme.bodyText1.copyWith(color: Colors.red))).toList(), );
  }


/*
  @override
  Widget build(BuildContext context) {
    return Selector<SudokuDataModel, Cell>(
      selector: (_, d) => d.getCell(widget._coords),
      /*
      shouldRebuild: (Cell o, Cell n) {
        print("shouldRebuild: ${o.toString()}, ${n.toString()}");
        if (o.selected != n.selected) {
          return true;
        }
        return false;
      },

       */
      builder: (_, cell, __) {
        var selected = cell.selected;
        var value = cell.value;

        print("build");
        return GestureDetector(
          onTapUp: (_) {
            print("click ${widget._coords.toString()}");
            context.read<SudokuDataModel>().setSelected(widget._coords);
          },
          child: Container(
              color: selected ? Colors.blue : Colors.white,
              child: Center(
                child: Text("$value", style: Theme.of(context).textTheme.headline4,),
              )
          ),
        );
      },
    );
  }
 */
}

