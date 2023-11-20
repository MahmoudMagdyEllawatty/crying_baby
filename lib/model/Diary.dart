
class Diary {
  String id;
  final String date;
  final String title;
  final String image;
  final String userKey;

  Diary({
  this.id = '',
  required this.date,
  required this.title,
    required this.image,
    required this.userKey
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['date'] = this.date;
    data['id'] = this.id;
    data['image'] = this.image;
    data['userKey'] = this.userKey;

    return data;
  }

  static Diary fromJson(Map<String,dynamic> json) => Diary(
      title : json['title'],
      id: json['id'],
      date : json['date'],
      image: json['image'],
      userKey: json['userKey']);
}