
class Vaccine {
  String id;
  final String day;
  final String description;
  final String name;

  Vaccine({
  this.id = '',
  required this.day,
  required this.description,
  required this.name
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['id'] = this.id;
    data['day'] = this.day;

    return data;
  }

  static Vaccine fromJson(Map<String,dynamic> json) => Vaccine(
      day : json['day'],
      id: json['id'],
      description : json['description'],
      name : json['name']);

}