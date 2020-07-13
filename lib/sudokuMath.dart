import 'package:http/http.dart' as http;
import 'package:quiver/core.dart';


const SudokuUrl = "http://cn.sudokupuzzle.org";

class SudokuData {
  List<List<Cell>> _data;  //大9宫二维数组
  int level;
  Map<Coords, int> _CoordsMap; //坐标归属于哪个小9宫(0-8个小9宫)


  SudokuData() {
    _CoordsMap = Map<Coords, int>();
    List.generate(9, (i) => SudokuCoords(i).forEach((e) => _CoordsMap[e] = i));
    print(_CoordsMap.toString());

    _data = List.generate(9, (x) => List<Cell>.generate(9, (y) {
      Set<Coords> brothers= Set();

      for(int i=0; i< 9; i++) {
        //x轴
        if (y != i) { brothers.add(Coords(x, i)); }

        //y轴
        if (x != i) { brothers.add(Coords(i, y)); }

      }

      //小9宫兄弟
      int i = _CoordsMap[Coords(x,y)];
//      print("----------$i");
      _CoordsMap.forEach((key, value) {
        if (i == value && key != Coords(x,y)) {
          brothers.add(key);
        }
      });
      return Cell(coords:Coords(x, y), brothers: brothers, value: 0);
    }));
  }

  //测试用的
  void initDataTest(List<int> d) {
    var i = 0;
    _data = List.generate(9, (x) => List<Cell>.generate(9, (y) {
      var value = d[i++];
      return Cell(
        coords:Coords(x, y),
        value: value,
        isEdit: value > 0 ? false : true,
      );
    }));
  }

  void initData(List<int> d) {
    var i = 0;
    for(var x=0; x<9; x++) {
      for(var y=0; y<9; y++) {
        var value = d[i++];
        var cell = _data[x][y];
        cell.clean();
        cell.value  = value;
        cell.isEdit = value > 0 ? false : true;
      }
    }

    printString();
  }

  bool success() {
    var i = 0;
    for(var x=0; x<9; x++) {
      for(var y=0; y<9; y++) {
        var cell = _data[x][y];
        if (cell.value  == 0 || cell.isError ) {
          return false;
        }
      }
    }

    print("Success....");

    for(var x=0; x<9; x++) {
      for(var y=0; y<9; y++) {
        _data[x][y].isEdit = false;
      }
    }
    return true;
  }

  Cell getCell(Coords c) => _data[c.x][c.y];

  void setValue(Coords c,  int value) {
    _data[c.x][c.y].value = value;
    _checkError(c);
  }

  void setNotes(Coords c, int note) {
    _data[c.x][c.y].notes.add(note);
  }
  void removeNotes(Coords c) {
    var notes = _data[c.x][c.y].notes;
//    notes.clear(); return;
    if (notes.length == 0) { return;}
    var last = notes.last;
    notes.remove(last);
  }

  //标记选中
  void setSelected(Coords c) => _data[c.x][c.y].selected = true;
  void unsetSelected(Coords c) => _data[c.x][c.y].selected = false;

  //标记点击区域相同数字
  void setSameValue(Coords c) {
    var v = _data[c.x][c.y].value;

    if (v == 0) {
      _data.forEach((e) => e.forEach((_e) => _e.sameValue = false));
      return;
    }
    _data.forEach((e) => e.forEach((_e) => _e.sameValue = _e.value == v ? true : false ));
  }

  void _checkError(Coords c) {
    var cell = _data[c.x][c.y];

    for (var e in cell.brothers) {
      var _cell = _data[e.x][e.y];
//      print("${cell.value} == ${_cell.value} : (${e.x}, ${e.y})");
      if (cell.value == _cell.value) {
        print("error value: ${cell.value}");
        cell.isError = true;
        return;
      }
    }

    cell.isError = false;
  }

  void printString() {
    print("${_data[0][1].toString()}");
    int i = 0;
    _data.forEach((e) {
      print("${e[0].value} ${e[1].value} ${e[2].value} | ${e[3].value} ${e[4].value} ${e[5].value} | ${e[6].value} ${e[7].value} ${e[8].value}");
      i++;
      if (i%3 == 0) {
        print("------+-------+------");
      }
    });
  }
}


/*
获取9宫格，每个格子的坐标
第1个格子的9个坐标
  00,01,02
  10,11,12
  20,21,22
*/
List<Coords> SudokuCoords (int index) {
  assert(index >= 0 &&  index < 9);
  int x, y;
  switch (index) {
    case 0:
      x = 0; y = 0;
      break;
    case 1:
      x = 0; y = 3;
      break;
    case 2:
      x = 0; y = 6;
      break;

    case 3:
      x = 3; y = 0;
      break;
    case 4:
      x = 3; y = 3;
      break;
    case 5:
      x = 3; y = 6;
      break;

    case 6:
      x = 6; y = 0;
      break;
    case 7:
      x = 6; y = 3;
      break;
    case 8:
      x = 6; y = 6;
      break;
  }

  List<Coords> list = [];
  for (var i=0; i<3; i++) {
    for (var j=0; j<3; j++) {
      var _x = x + i;
      var _y = y + j;
      list.add(Coords(_x, _y));
    }
  }
  return list;
}


//最小单元
class Cell {
  final Coords coords;//坐标
  final Set<Coords> brothers; //大9宫横竖，以及小9宫兄弟位置, assert(brothers.length==20)个坐标
  Set<int> notes;   //存放笔记
  int value;        //填入的值[0-9]
  bool selected;    //被点中
  bool sameValue;   //被选中相同的值
  bool isEdit;      //是否可编辑 判断是题目
  bool isError;     //value  是否正确

  Cell({this.coords, this.brothers, this.value,
    this.isEdit=false, this.isError=false, this.selected=false, this.sameValue=false}) {
    notes = Set();
  }

  void clean() {
    value = 0;
    selected = false;  //被点中
    sameValue = false; //被选中相同的值
    isEdit = false; //是否可编辑 判断是题目
    isError = false; //value  是否正确
    notes.clear();
  }

  String toString() {
    return
"""
--------------------
${coords.toString()}
value     = $value 
notes     = ${notes.toString()}
selected  = $selected 
sameValue = $sameValue 
isEdit    = $isEdit 
isError   = $isError
brothers  = ${brothers.length}: ${brothers.toString()}
--------------------
""";
  }
}

//坐标
class Coords extends Object{
  final int x;
  final int y;

  Coords(this.x, this.y) {
    assert(x >= 0 && x <9);
    assert(y >= 0 && y <9);
  }

  @override
  bool operator ==(dynamic c) => c is Coords &&  x == c.x && y == c.y;
  int get hashCode => hash2(x.hashCode, y.hashCode);


  String toString() {
    return "Coords($x, $y)";
  }

}


//
//从网上获取题目
Future<List<int>> getWebData(int level) async {
//    assert(level >=0 && level < SudokuLevel.length);

    //获取网页中的题目正则
    RegExp reg = RegExp(r"(\d{81})", multiLine:true);
    var dt = DateTime.now();

    List<int> list = [];
    String body;
    var url = "$SudokuUrl/online2.php?nd=$level&y=${dt.year}&m=${dt.month}&d=${dt.day}";
//    var url = "http://cn.sudokupuzzle.org/online2.php";
    print(url);

    var client = http.Client();
    try {
      var rsp = await client.get(url);
      body = rsp.body.toString();
    } finally{
      client.close();
    }

    /*
    body = '''function newClick()
  {
    var tmda;
    tmda='06000080097002003685001000071025004304603801029004600718500792440700130863900207536297485197182543685461379271825964354673821929314658718536792442759136863948217519217';
    document.getElementById('tm').value  =  tmda.substring(0,81);
    document.getElementById('da').value  =  tmda.substring(81,162);
    document.getElementById('nd').value  =  tmda.substring(162,163);
    document.getElementById('tmxh').value  =  tmda.substring(163,170);
    drawsudoku();
    drawcookie();
  }
  ''';
    print(body);
     */
    var match = reg.firstMatch(body);
    if (match == null) {
      print("no result");
      return null;
    }
    print("match1 = ${match.groupCount}");

    var str = match.group(1);

    print(str);
    for (var i=0; i<81; i++) {
      list.add(int.parse(str[i]));
    }
    print(list.length);

    return list;
}