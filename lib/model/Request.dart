
class Request {
  late String id = "";
  late String employer_id = "";
  late String date = "";
  late String from_date = "";
  late String to_date = "";
  late String state = "";
  late String notes = "";
  late String type = "";
  late String created_at = "";

  Request.empty();

  Request(this.id,this.employer_id,this.date,this.from_date,this.to_date,this.state,this.notes,this.type,this.created_at);


  Request.fromJson(Map<String,dynamic> json): id=json['id'],employer_id=json['employer_id'],date=json['date'],
  from_date=json['from_date'],to_date=json['to_date'],state=json['state'],notes=json['notes'],type=json['type'],
  created_at=json['created_at'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['employer_id'] = this.employer_id;
    data['date'] = this.date;
    data['from_date'] = this.from_date;
    data['to_date'] = this.to_date;
    data['state'] = this.state;
    data['notes'] = this.notes;
    data['type'] = this.type;
    data['created_at'] = this.created_at;
    return data;
  }

}