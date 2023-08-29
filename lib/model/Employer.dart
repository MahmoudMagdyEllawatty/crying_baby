
class Employer {
  late String name;
  late String phone;
  late String id;

  Employer.empty();

  Employer(this.id,this.name,this.phone);

  factory Employer.fromMap(Map<String,dynamic> json){
    return Employer(
        json['id'],json['name'], json['phone']!
    );
  }

  Employer.fromJson(Map<String,dynamic> json): id=json['id'],name=json['name'],phone=json['phone'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    return data;
  }

}