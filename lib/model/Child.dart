
class Child {
  String id;
  final String name;
  final String birth_date;
  final String userKey;
  final String sexType;

  Child({
  this.id = '',
  required this.name,
  required this.birth_date,
    required this.userKey,
    required this.sexType
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['birth_date'] = this.birth_date;
    data['id'] = this.id;
    data['userKey'] = this.userKey;
    data['sexType'] = this.sexType;

    return data;
  }

  static Child fromJson(Map<String,dynamic> json) => Child(
      name : json['name'],
      id: json['id'],
      birth_date : json['birth_date'],
      sexType: json['sexType'],
      userKey: json['userKey']);
}