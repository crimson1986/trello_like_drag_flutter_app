class BoardListDraggableItem {
  int itemIndex;
  int draggedListIdentifier;

  BoardListDraggableItem({this.itemIndex, this.draggedListIdentifier})
      : assert(draggedListIdentifier != null),
        assert(itemIndex != null);
}
