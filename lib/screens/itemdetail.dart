import 'package:flutter/material.dart';
import 'package:speak/models/item.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:speak/utils/dbhelper.dart';
import 'package:intl/intl.dart';

DbHelper helper = DbHelper();
final List<String> choices = const <String>[
  'Save Item & Back',
  'Delete Item',
  'Back to Items'
];

const mnuSave = 'Save Item & Back';
const mnuDelete = 'Delete Item';
const mnuBack = 'Back to Items';

class ItemDetail extends StatefulWidget {
  final Item item;

  ItemDetail(this.item);

  @override
  State createState() => ItemDetailState(item);
}

class ItemDetailState extends State {
  Item item;
  ItemDetailState(this.item);

  final _types = ["Button", "Category"];
  String _type = "Button";

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = item.title;
    descriptionController.text = item.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(
          title: Text(item.title),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: select,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ]),
      body: Padding(
        padding: EdgeInsets.only(
          top: 35.0,
          left: 10.0,
          right: 10.0,
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) => this.updateTitle(),
                  decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0,
                    bottom: 15.0,
                  ),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) => this.updateDescription(),
                    decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                  ),
                ),
                ListTile(
                  title: DropdownButton<String>(
                    items: _types.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: retrieveType(item.type),
                    style: textStyle,
                    onChanged: (value) => updateType(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void select(String value) async {
    int result;
    switch (value) {
      case mnuSave:
        save();
        break;
      case mnuDelete:
        Navigator.pop(context, true);
        if (item.id == null) {
          return;
        }
        result = await helper.deleteItem(item.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text('Delete Item'),
            content: Text('The item has been deleted'),
          );
          showDialog(
            context: context,
            builder: (_) => alertDialog,
          );
        }
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
    }
  }

  void save() {
    item.date = DateFormat.yMd().format(DateTime.now());
    if (item.id != null) {
      helper.updateItem(item);
    } else {
      helper.insertItem(item);
    }
    Navigator.pop(context, true);
  }

  void updateType(String value) {
    switch (value) {
      case "Button":
        item.type = 0;
        break;
      case "Category":
        item.type = 1;
        break;
//      case "Low":
//        item.priority = 3;
//        break;
      default:
        item.type = 0;
        break;
    }
    setState(() {
      _type = value;
    });
  }

  String retrieveType(int value) {
    return _types[value];
  }

  void updateTitle() {
    item.title = titleController.text;
  }

  void updateDescription() {
    item.description = descriptionController.text;
  }
}
