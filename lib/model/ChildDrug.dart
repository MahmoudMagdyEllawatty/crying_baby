
import 'package:intl/intl.dart';

class ChildDrug {
  String id;
  final String childKey;
  final String drug;
  final String date;
  final String end_date;
  final String dosage;
  final String times;
  final int state;
  

  ChildDrug({
  this.id = '',
  required this.childKey,
  required this.drug,
    required this.date,
    required this.end_date,
    required this.dosage,
    required this.times,
    required this.state
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['childKey'] = this.childKey;
    data['drug'] = this.drug;
    data['id'] = this.id;
    data['date'] = this.date;
    data['state'] = this.state;
    data['end_date'] = this.end_date;
    data['dosage'] = this.dosage;
    data['times'] = this.times;

    return data;
  }

  static ChildDrug fromJson(Map<String,dynamic> json) => ChildDrug(
      childKey : json['childKey'],
      id: json['id'],
      drug : json['drug'],
      date : json['date'],
      dosage: json['dosage'],
      times: json['times'],
      state:  json['state'] ?? 0,
  end_date: json['end_date'] ?? '');
}