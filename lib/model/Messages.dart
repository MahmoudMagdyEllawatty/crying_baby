
class Messages {
  String id;
  final String description;
  final String title;

  Messages({
  this.id = '',
  required this.description,
  required this.title
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['id'] = this.id;

    return data;
  }

  static Messages fromJson(Map<String,dynamic> json) => Messages(
      title : json['title'],
      id: json['id'],
      description : json['description']);
}