import 'package:cloud_firestore/cloud_firestore.dart';

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
