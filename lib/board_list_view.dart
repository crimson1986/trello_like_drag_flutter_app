import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/Database/datamanager.dart';
import 'package:flutter_app/board_list_draggable_item.dart';

import 'Models/board_list_item_model.dart';
import 'Models/board_list_model.dart';
import 'board_list.dart';

class BoardListView extends StatefulWidget {
  BoardListView({Key key}); //: assert(listModels != null);

  @override
  _BoardListViewState createState() => _BoardListViewState();
}

class _BoardListViewState extends State<BoardListView> {
  final ScrollController _scrollController = ScrollController();
  bool _isDraggedStarted = false;
  bool _isAnimating = false;
  double _initdx;
  double _dy;
  double _initScrollPosX;
  final double listWidth = 400;
  final DataManager _dataManager = DataManager();
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dataManager.collection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        totalCount = snapshot.data.documents.length;

        return Container(
          child: _buildList(context, snapshot.data.documents),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView(
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      children: snapshots.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    var bordListDetails = BoardListModel.fromSnapshot(data);

    return Container(
        width: listWidth,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Listener(
          onPointerMove: (event) {
            _scrollToPosition(event, context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: BoardList(
                bordListDetails: bordListDetails,
                itemBuilder: (ctx, index) {
                  return Card(
                    key: ValueKey(
                        "ItemIdentifier_${bordListDetails.items[index].title}_${index.toString()}"),
                    child: ListTile(
                        leading: Icon(Icons.photo),
                        title: Text(bordListDetails.items[index].title)),
                  );
                },
                onDropItem: _dropItemHandler,
                willDropItemAccept: (data) {
                  return true;
                },
                onDragCompleted: () {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
                onDragEnd: (details) {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
                onDragStarted: () {
                  _isDraggedStarted = true;
                  _resetInitFlags();
                },
                onDraggableCanceled: (velocity, offset) {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
              ))
            ],
          ),
        ));
  }

  void _scrollToPosition(PointerEvent event, BuildContext context) {
    if (_isDraggedStarted && !_isAnimating) {
      if (_initdx == null) {
        _initdx = event.position.dx;
        _dy = event.position.dy;
      }

      if (event.position.dy.round() >= (_dy + 5).round() ||
          event.position.dy.round() <= (_dy - 5).round()) {
        _dy = event.position.dy;
        return;
      }
      if (_initScrollPosX == null) {
        _initScrollPosX = _scrollController.position.pixels;
        if (_initScrollPosX.isNegative) {
          _initScrollPosX = 0;
        }
      }

      double wd = listWidth;

      if (event.position.dx < wd - 10 && event.position.dx > 20) {
        return;
      }

      int totalList = totalCount;
      double scrollLimit = (totalList * wd.ceil()).toDouble();

      double diff = 5;
      if (event.position.dx > _initdx + diff && _scrollController.hasClients) {
        // moving right
        double delta = (event.position.dx - _initdx);

        _initScrollPosX += delta;
        if (_initScrollPosX.isNegative) {
          _initScrollPosX = 0;
        }
        if (_initScrollPosX > scrollLimit) {
          _initScrollPosX = scrollLimit;
        }

        _isAnimating = true;
        _scrollController
            .animateTo(_initScrollPosX,
                duration: Duration(milliseconds: 400), curve: Curves.ease)
            .whenComplete(() => _isAnimating = false);
      } else if (event.position.dx < _initdx - diff &&
          _scrollController.hasClients) {
        // moving left
        double delta = (_initdx - event.position.dx);
        _initScrollPosX -= delta;

        if (_initScrollPosX.isNegative) {
          _initScrollPosX = 0;
        }

        if (!_initScrollPosX.isNegative) {
          _isAnimating = true;
          _scrollController
              .animateTo(_initScrollPosX,
                  duration: Duration(milliseconds: 400), curve: Curves.ease)
              .whenComplete(() => _isAnimating = false);
        }
      }
    }
  }

  void _resetInitFlags() {
    _initdx = null;
    _dy = null;
    _initScrollPosX = null;
  }

  void _dropItemHandler(BoardListModel onDropList,
      BoardListDraggableItem dragList, int index) async {
    var newIndex = index;
    if (newIndex > onDropList.items.length) {
      newIndex = onDropList.items.length - 1;
    }
    var dataIndex = dragList.itemIndex;

    // if we move item into different list
    if (onDropList.identifierIndex != dragList.draggedListIdentifier) {
      var identifier = dragList.draggedListIdentifier;
      var draggedOldListDocuments =
          await _dataManager.collection.getDocuments();
      var draggedOldListSnapshot = draggedOldListDocuments.documents
          .where((element) => element.data['index'] == identifier)
          .first;
      var draggedOldList = BoardListModel.fromSnapshot(draggedOldListSnapshot);
      if (draggedOldList != null) {
        var draggedItem = draggedOldList.items[dataIndex];
        // insert in new list

        draggedItem.position = newIndex;

        onDropList.items.insert(newIndex, draggedItem);
        onDropList.items.sublist(newIndex + 1).forEach((element) {
          element.position = element.position + 1.toInt();
        });

        // remove from old list

        draggedOldList.items.removeAt(dataIndex);
        draggedOldList.items.sublist(dataIndex).forEach((element) {
          element.position = element.position - 1.toInt();
        });

        _dataManager.updateBoardListModel(onDropList);
        _dataManager.updateBoardListModel(draggedOldList);
      }

      return;
    }

    if (newIndex >= onDropList.items.length) {
      newIndex = onDropList.items.length - 1;
    }

    // if list is same

    BoardListItemModel itemToMove = onDropList.items[dataIndex];
    int pevIndex = itemToMove.position;
    itemToMove.position = newIndex;

    onDropList.items.removeAt(dataIndex);
    onDropList.items.insert(newIndex, itemToMove);

    if (pevIndex > newIndex) {
      onDropList.items.sublist(newIndex, pevIndex).forEach((element) {
        element.position = element.position + 1.toInt();
      });
    } else if (pevIndex < newIndex) {
      onDropList.items.sublist(pevIndex, newIndex).forEach((element) {
        element.position = element.position - 1.toInt();
      });
    }

    _dataManager.updateBoardListModel(onDropList);
  }

  // builder methods

  /*ListView _buildListBuilder(AsyncSnapshot<QuerySnapshot> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.documents.length,
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot data = snapshot.data.documents[index];
        return _buildListItem(context, data);
      },
    );
  }

  Widget _boardListItemBuilder(BuildContext context, int index) {
    var bordListDetails = widget.listModels[index];
    final double listWidth = 400;

    return Container(
        width: listWidth,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Listener(
          onPointerMove: (event) {
            _scrollToPosition(event, context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: BoardList(
                bordListDetails: bordListDetails,
                itemBuilder: (ctx, index) {
                  return Card(
                    key: ValueKey(
                        "ItemIdentifier_${bordListDetails.items[index].title}_${index.toString()}"),
                    child: ListTile(
                        leading: Icon(Icons.photo),
                        title: Text(bordListDetails.items[index].title)),
                  );
                },
                onDropItem: _dropItemHandler,
                willDropItemAccept: (data) {
                  return true;
                },
                onDragCompleted: () {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
                onDragEnd: (details) {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
                onDragStarted: () {
                  _isDraggedStarted = true;
                  _resetInitFlags();
                },
                onDraggableCanceled: (velocity, offset) {
                  _isDraggedStarted = false;
                  _resetInitFlags();
                },
              ))
            ],
          ),
        ));
  }*/
}
