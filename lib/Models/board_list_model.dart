import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/board_list_item_model.dart';

// class BoardListModel {
//   String headerTitle;
//   int identifierIndex;
//   List<BoardListItemModel> items;

//   BoardListModel({this.headerTitle, this.items, this.identifierIndex})
//       : assert(identifierIndex != null) {
//     if (this.headerTitle == null) {
//       this.headerTitle = "";
//     }

//     if (this.items == null) {
//       this.items = [];
//     }
//   }
// }

class BoardListModel {
  String headerTitle;
  int identifierIndex;
  List<BoardListItemModel> items = List<BoardListItemModel>();
  DocumentReference reference;

  BoardListModel(this.headerTitle, this.identifierIndex,
      {this.items, this.reference});

  factory BoardListModel.fromSnapshot(DocumentSnapshot snapshot) {
    BoardListModel lists = BoardListModel.fromJson(snapshot.data);
    lists.reference = snapshot.reference;
    return lists;
  }

  factory BoardListModel.fromJson(Map<dynamic, dynamic> json) =>
      _listsFromJson(json);

  Map<String, dynamic> toJson() => _listsToJson(this);
  @override
  String toString() => "BoardListModel<$headerTitle>";
}

class BoardListItemModel {
  String title;
  int position;
  DocumentReference reference;

  BoardListItemModel(this.title, {this.position, this.reference});

  factory BoardListItemModel.fromJson(Map<dynamic, dynamic> json) =>
      _listItemFromJson(json);

  Map<String, dynamic> toJson() => _listItemToJson(this);

  @override
  String toString() => "BoardListItemModel<$title>";
}

BoardListItemModel _listItemFromJson(Map<dynamic, dynamic> json) {
  return BoardListItemModel(
    json['title'] as String,
    position: json['position'] == null ? 0 : (json['position'] as int),
  );
}

Map<String, dynamic> _listItemToJson(BoardListItemModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'position': instance.position,
    };

//1
BoardListModel _listsFromJson(Map<dynamic, dynamic> json) {
  return BoardListModel(
      json['headerTitle'], json['index'] == null ? 0 : json['index'] as int,
      items: _convertListItems(json['items'] as List));
}

// 2
List<BoardListItemModel> _convertListItems(List listItemMap) {
  if (listItemMap == null) {
    return null;
  }
  List<BoardListItemModel> vaccinations = List<BoardListItemModel>();
  listItemMap.forEach((value) {
    vaccinations.add(BoardListItemModel.fromJson(value));
  });
  return vaccinations;
}

// 3
Map<String, dynamic> _listsToJson(BoardListModel instance) => <String, dynamic>{
      'headerTitle': instance.headerTitle,
      'index': instance.identifierIndex,
      'items': _listItemList(instance.items),
    };
// 4
List<Map<String, dynamic>> _listItemList(List<BoardListItemModel> item) {
  if (item == null) {
    return null;
  }
  List<Map<String, dynamic>> listItemMap = List<Map<String, dynamic>>();
  item.forEach((listItem) {
    listItemMap.add(listItem.toJson());
  });
  return listItemMap;
}
