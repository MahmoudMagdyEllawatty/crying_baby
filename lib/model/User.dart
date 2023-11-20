
class User {
  String id;
  final String name;
  final String email;
  final String password;

  User({
  this.id = '',
  required this.name,
  required this.email,
    required this.password
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['id'] = this.id;
    data['password'] = this.password;

    return data;
  }

  static User fromJson(Map<String,dynamic> json) => User(
      name : json['name'],
      id: json['id'],
      email : json['email'],
      password: json['password']);
}