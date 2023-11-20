
class Advices {
  String id;
  final String description;
  final String title;
  final String image;

  Advices({
  this.id = '',
  required this.description,
  required this.title,
    required this.image
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['id'] = this.id;
    data['image'] = this.image;

    return data;
  }

  static Advices fromJson(Map<String,dynamic> json) => Advices(
      title : json['title'],
      id: json['id'],
      description : json['description'],
      image: json['image']);
}