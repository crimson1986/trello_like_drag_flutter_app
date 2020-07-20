import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/Models/board_list_model.dart';
import 'package:flutter_app/Models/board_list_item_model.dart';

class DataManager {
  final CollectionReference collection = Firestore.instance.collection('Lists');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  updateBoardListModel(BoardListModel lists) async {
    await collection
        .document(lists.reference.documentID)
        .updateData(lists.toJson());
  }

  updateBoardListItemModel(BoardListItemModel listItem) async {
    await collection
        .document(listItem.reference.documentID)
        .updateData(listItem.toJson());
  }
}
