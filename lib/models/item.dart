class Item {
  int _id;
  String _title;
  String _description;
  String _date;
  int _type;

  Item(this._title, this._type, this._date, [this._description]);
  Item.withId(this._id, this._title, this._type, this._date,
      [this._description]);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get type => _type;

  set title(String newTitle) {
    if (newTitle.length < 255) {
      _title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length < 255) {
      _description = newDescription;
    }
  }

  set type(int newType) {
    if (newType >= 0 && newType <= 3) {
      _type = newType;
    }
  }

  set date(String newDate) {
    if (newDate != null) {
      _date = newDate;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["title"] = _title;
    map["description"] = _description;
    map["type"] = _type;
    map["date"] = _date;
    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  Item.fromObject(dynamic o) {
    this._id = o["id"];
    this._title = o["title"];
    this._description = o["description"];
    this._type = o["type"];
    this._date = o["date"];
  }
}
