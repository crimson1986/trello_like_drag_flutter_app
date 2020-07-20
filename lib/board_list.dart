import 'package:flutter/material.dart';
import 'package:flutter_app/Models/board_list_model.dart';

import 'sortable_list_view.dart';

class BoardList extends StatefulWidget {
  final BoardListModel bordListDetails;
  final IndexedWidgetBuilder itemBuilder;
  final OnDropItem onDropItem;
  final WillDropItemAccept willDropItemAccept;
  final VoidCallback onDragStarted;
  final DraggableCanceledCallback onDraggableCanceled;
  final DragEndCallback onDragEnd;
  final VoidCallback onDragCompleted;

  const BoardList({
    Key key,
    this.bordListDetails,
    this.itemBuilder,
    this.onDropItem,
    this.willDropItemAccept,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragEnd,
    this.onDraggableCanceled,
  }) : super(key: key);

  @override
  _BoardListState createState() => _BoardListState();
}

class _BoardListState extends State<BoardList> {
  @override
  Widget build(BuildContext context) {
    var header = Text(widget.bordListDetails.headerTitle);
    var listContainer = _buildSortableListView();
    return Container(
        margin: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [header, listContainer],
        ));
  }

  Container _buildSortableListView() {
    return Container(
        child: SortableListView(
      list: widget.bordListDetails,
      itemBuilder: widget.itemBuilder,
      onDropItem: widget.onDropItem,
      willDropItemAccept: widget.willDropItemAccept,
      onDragCompleted: widget.onDragCompleted,
      onDragEnd: widget.onDragEnd,
      onDragStarted: widget.onDragStarted,
      onDraggableCanceled: widget.onDraggableCanceled,
    ));
  }
}
