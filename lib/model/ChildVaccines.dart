
import 'package:CryingBaby/model/Vaccine.dart';

class ChildVaccines {
  String id;
  final String childKey;
  final String vaccine;
  final String date;
  final int state;
  final String image;

  ChildVaccines({
  this.id = '',
  required this.childKey,
  required this.vaccine,
    required this.date,
    required this.state,
    required this.image
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['childKey'] = this.childKey;
    data['vaccine'] = this.vaccine;
    data['id'] = this.id;
    data['date'] = this.date;
    data['state'] = this.state;
    data['image'] = this.image;
    return data;
  }

  static ChildVaccines fromJson(Map<String,dynamic> json) => ChildVaccines(
      childKey : json['childKey'],
      id: json['id'],
      vaccine : json['vaccine'],
      date : json['date'],
      state:  json['state'] ?? 0,
  image: json['image'] ?? '');
}