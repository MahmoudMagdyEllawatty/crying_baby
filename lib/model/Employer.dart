
class Employer {
  late String name;
  late String phone;
  late String id;
  late String image = "images/avatar.png";

  Employer.empty();

  Employer(this.id,this.name,this.phone,this.image);

  factory Employer.fromMap(Map<String,dynamic> json){
    return Employer(
        json['id'],json['name'], json['phone']!,json['image']
    );
  }

  Employer.fromJson(Map<String,dynamic> json): id=json['id'],name=json['name'],phone=json['phone'],image=json['image'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['image'] = this.image;
    return data;
  }

}