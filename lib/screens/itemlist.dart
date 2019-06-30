import 'package:flutter/material.dart';
import 'package:speak/utils/dbhelper.dart';
import 'package:speak/models/item.dart';
import 'package:speak/screens/itemdetail.dart';
import 'package:speak/components/rounded_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io';

enum TtsState { playing, stopped }

class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ItemListState();
}

class ItemListState extends State<ItemList> {
  DbHelper helper = DbHelper();
  List<Item> items;
  int count = 0;
  FlutterTts flutterTts;
  dynamic languages;
  dynamic voices;
  String language;
  String voice;

  TtsState ttsState;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (Platform.isAndroid) {
      flutterTts.ttsInitHandler(() {
        _getLanguages();
        _getVoices();
      });
    } else if (Platform.isIOS) {
      _getLanguages();
      _getVoices();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setVolume(1.0);
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
    if (voices != null) setState(() => voices);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      items = List<Item>();
      getData();
    }
    return Scaffold(
      body: itemListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Item('', 0, ''));
        },
        tooltip: "Add New Item",
        child: Icon(Icons.add),
      ),
    );
  }

  Color getColor(int type) {
    switch (type) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  ListView itemListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 5.0,
          borderOnForeground: true,
          child: RoundedButton(
              title: items[position].title,
              color: Colors.grey,
              onPressed: () {
                speak(items[position].title);
              }),
        );
      },
    );
  }

  void getData() {
    // Initial insert for test
//    DateTime today = DateTime.now();
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
//      Item item = Item(
//          "Good morning!", 0, today.toString(), "And make sure they are good");
//      helper.insertItem(item);
      final todosFuture = helper.getItems();
      todosFuture.then((result) {
        List<Item> itemList = List<Item>();
        count = result.length;
        for (int i = 0; i < count; i++) {
          itemList.add(Item.fromObject(result[i]));
          debugPrint(itemList[i].title);
        }
        setState(() {
          items = itemList;
          count = count;
          debugPrint("Items " + count.toString());
        });
      });
    });
  }

  void navigateToDetail(Item item) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemDetail(item)),
    );
    if (result == true) {
      getData();
    }
  }

  Future speak(String phrase) async {
    if (phrase != null) {
      if (phrase.isNotEmpty) {
        print("Say \'$phrase\'");
        var result = await flutterTts.speak(phrase);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }
}
