
class Company {
  late String name = "";
  late String image = "images/site/ii99yNWyf0FWvCGbbj6EtXAF1vdGwSD8JNe8htbb.png";
  late String enable_early_exit;

  Company.empty();

  Company(this.name,this.image,this.enable_early_exit);


  Company.fromJson(Map<String,dynamic> json): image=json['image'],name=json['name'],enable_early_exit=json['enable_early_exit'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['image'] = this.image;
    data['enable_early_exit'] = this.enable_early_exit;
    return data;
  }

}