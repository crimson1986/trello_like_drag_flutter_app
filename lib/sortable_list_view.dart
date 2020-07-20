import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'Models/board_list_model.dart';
import 'board_list_draggable_item.dart';

// when item drop
typedef void OnDropItem(
    BoardListModel onDropList, BoardListDraggableItem dragList, int index);
typedef bool WillDropItemAccept(BoardListDraggableItem data);

class SortableListView extends StatefulWidget {
  final BoardListModel list;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback onDragStarted;
  final DraggableCanceledCallback onDraggableCanceled;
  final DragEndCallback onDragEnd;
  final VoidCallback onDragCompleted;
  final OnDropItem onDropItem;
  final WillDropItemAccept willDropItemAccept;

  SortableListView(
      {Key key,
      this.list,
      this.itemBuilder,
      this.onDropItem,
      this.willDropItemAccept,
      this.onDragStarted,
      this.onDragCompleted,
      this.onDragEnd,
      this.onDraggableCanceled})
      : assert(list != null),
        assert(itemBuilder != null);

  @override
  State createState() => SortableListViewState();
}

class SortableListViewState extends State<SortableListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return _buildReorderableListView(context);
  }

  Widget _buildReorderableListView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        var _items = widget.list.items;
        _items.sort((a, b) => (a.position.compareTo(b.position)));

        return ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          controller: _scrollController,
          itemCount: _items.length + 1,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            var _draggedItem = BoardListDraggableItem(
                draggedListIdentifier: widget.list.identifierIndex,
                itemIndex: index);

            return Listener(
              onPointerMove: (event) {
                // print(event.position);
              },
              child: LongPressDraggable<BoardListDraggableItem>(
                data: _draggedItem,
                maxSimultaneousDrags: 1,
                child: _dragTarget(_draggedItem),
                onDragCompleted: () {
                  if (widget.onDragCompleted != null) {
                    widget.onDragCompleted();
                  }
                },
                onDragEnd: (details) {
                  if (widget.onDragEnd != null) {
                    widget.onDragEnd(details);
                  }
                },
                onDragStarted: () {
                  if (widget.onDragStarted != null) {
                    widget.onDragStarted();
                  }
                },
                onDraggableCanceled: (velocity, offset) {
                  if (widget.onDraggableCanceled != null) {
                    widget.onDraggableCanceled(velocity, offset);
                  }
                },
                feedback: Opacity(
                  opacity: 0.75,
                  child: SizedBox(
                    width: constraint.maxWidth,
                    child: _getListItem(context, _draggedItem, true),
                  ),
                ),
                childWhenDragging: Container(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dragTarget(BoardListDraggableItem draggedItem) {
    var index = draggedItem.itemIndex;

    return DragTarget<BoardListDraggableItem>(
      onWillAccept: (data) {
        if (widget.willDropItemAccept == null) {
          return true;
        }
        return widget.willDropItemAccept(data);
      },
      onAccept: (BoardListDraggableItem data) {
        _handleAccept(data, index);
      },
      builder: (BuildContext context, List<BoardListDraggableItem> data,
          List<dynamic> rejects) {
        List<Widget> children = [];

        if (data.isNotEmpty) {
          children.add(
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[600], width: 2.0),
              ),
              child: Opacity(
                opacity: 0.5,
                child: _getListItem(context, data[0]),
              ),
            ),
          );
        }
        children.add(_getListItem(context, draggedItem));

        return Column(
          children: children,
        );
      },
    );
  }

  void _handleAccept(BoardListDraggableItem data, int index) {
    setState(() {
      if (widget.onDropItem != null) {
        widget.onDropItem(widget.list, data, index);
      }
    });
  }

  Widget _getListItem(BuildContext context, BoardListDraggableItem draggedItem,
      [bool dragged = false]) {
    var index = draggedItem.itemIndex;

    if (index == widget.list.items.length) {
      if (widget.list.items.isEmpty) {
        return Container();
      }
      var newDragItem = BoardListDraggableItem(
          draggedListIdentifier: draggedItem.draggedListIdentifier,
          itemIndex: index - 1);
      return Opacity(
        opacity: 0.0,
        child: _getListItem(context, newDragItem),
      );
    }

    return Material(
      elevation: dragged ? 20.0 : 0.0,
      child: widget.itemBuilder(context, index),
    );
  }
}
