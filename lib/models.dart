import 'package:flutter/foundation.dart';
import 'package:sudoku/sudokuMath.dart';

/*
url: http://cn.sudokupuzzle.org/
level:
0: 入门
1: 初级
2: 中级
3: 高级
4: 骨灰级
const Map<int, String> SudokuLevel = {
  0: "入门",
  1: "初级",
  2: "中级",
  3: "高级",
  4: "骨灰",
};
 */
const Map<int, String> SudokuLevel = {
  0: "Rookie",
  1: "Easy",
  2: "Normal",
  3: "Hard",
  4: "Unbelievably",
};

class SudokuControlModel with ChangeNotifier, DiagnosticableTreeMixin {
  //等级变量
  int _groupValue=0;
  get groupValue => _groupValue;

  //笔记模式
  bool _isNoteMode = false;
  get isNoteMode => _isNoteMode;

  void setNoteMode() {
    _isNoteMode = !_isNoteMode;
    print("isNoteModel: $_isNoteMode");
    notifyListeners();
  }

  void setGroupValue(int i) {
    assert(i>=0 && i<=4);
    _groupValue = i;
    notifyListeners();
  }
}

//#00001020048006300030057090021870946360520180700740000119362074850039000082604005975981423648296317536157298421875946364523189793748652119362574857439861282614735919207
class SudokuDataModel with ChangeNotifier, DiagnosticableTreeMixin {
  //完成
  bool _success = false;
  bool get success => _success;
  void setSuccess() => _success = true;

  //当前题目ID
  int examinationID;

  SudokuData _data = SudokuData();

  Coords _selectedCoords;

  void initData(List<int> d) {
    _success = false;
    examinationID = 0;
    _selectedCoords = null;

    _data.initData(d);
    notifyListeners();
  }

  void setValue(int value) {
    print("setValue: $value");
    //没有单元被选中 //不可编辑
    if (_selectedCoords == null || !_data.getCell(_selectedCoords).isEdit) { return; }

    _data.setValue(_selectedCoords, value);

    //标记相同数字
    _data.setSameValue(_selectedCoords);

    //是否完成
    _success = _data.success();
    notifyListeners();
  }

  void setNotes(int value) {
    print("setNotes: $value");
    //没有单元被选中 //不可编辑
    if (_selectedCoords == null || !_data.getCell(_selectedCoords).isEdit) { return; }

    _data.setNotes(_selectedCoords, value);
    notifyListeners();
  }

  void removeNotes() {
    //没有单元被选中 //不可编辑
    if (_selectedCoords == null || !_data.getCell(_selectedCoords).isEdit) { return; }

    print("removeNotes $_selectedCoords");
    _data.removeNotes(_selectedCoords);
    notifyListeners();
  }

  //选中并高亮相同数字
  void setSelected(Coords c) {
    print("setSelected ${c.toString()}");
    if (_selectedCoords != null) {
      _data.unsetSelected(_selectedCoords);
    }
    _data.setSelected(c);
    _selectedCoords = c;

    //标记相同数字
    _data.setSameValue(c);
    notifyListeners();
  }

  //处理Backspace == 0
  void doBackspace() {
    getCell(_selectedCoords).value > 0 ? setValue(0) : removeNotes();
  }

  Cell getCell(Coords c) => _data.getCell(c);
}

