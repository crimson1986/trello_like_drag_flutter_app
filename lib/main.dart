import 'package:flutter/material.dart';

import 'board_list_view.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  // List<BoardListModel> rows = new List<BoardListModel>()
  //   ..add(BoardListModel(
  //       headerTitle: "Task List",
  //       items: [
  //         BoardListItemModel(title: "Task 1"),
  //         BoardListItemModel(title: "Task 2")
  //       ],
  //       identifierIndex: 0))
  //   ..add(BoardListModel(
  //       headerTitle: "ToDos",
  //       items: [
  //         BoardListItemModel(title: "Task 3"),
  //         BoardListItemModel(title: "Task 4")
  //       ],
  //       identifierIndex: 1))
  //   ..add(BoardListModel(
  //       headerTitle: "Completed",
  //       items: [
  //         BoardListItemModel(title: "Task 5"),
  //         BoardListItemModel(title: "Task 6")
  //       ],
  //       identifierIndex: 2));

  @override
  Widget build(BuildContext context) {
    final title = 'Sortable ListView';

    return new MaterialApp(
      title: title,
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: BoardListView(),
      ),
    );
  }
}
