
class WorkingHour {
  late String day;
  late String attend_time;
  late String leave_time;

  WorkingHour.empty();

  WorkingHour(this.day,this.attend_time,this.leave_time);


  WorkingHour.fromJson(Map<String,dynamic> json): day=json['day'],attend_time=json['attend_time'],leave_time=json['leave_time'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['attend_time'] = this.attend_time;
    data['leave_time'] = this.leave_time;
    return data;
  }

}