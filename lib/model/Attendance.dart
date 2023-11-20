
class Attendance {
  late String id;
  late String employer_id;
  late String day;
  late String attend_at;
  late String leave_at;
  late String device;
  late String actual_attend_at;
  late String actual_leavel_at;

  Attendance.empty();

  Attendance(this.day,this.id,this.attend_at,this.device,this.employer_id,this.leave_at,
      this.actual_attend_at,this.actual_leavel_at);


  Attendance.fromJson(Map<String,dynamic> json):
        leave_at=json['leave_at'],
        employer_id=json['employer_id'],
        device=json['device'],
        attend_at=json['attend_at'],
        id=json['id'],
        day=json['day'],
        actual_attend_at=json['actual_attend_at'],
        actual_leavel_at=json['actual_leavel_at']
  ;

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leave_at'] = this.leave_at;
    data['employer_id'] = this.employer_id;
    data['attend_at'] = this.attend_at;
    data['id'] = this.id;
    data['day'] = this.day;
    data['actual_leavel_at'] = this.actual_leavel_at;
    data['actual_attend_at'] = this.actual_attend_at;

    return data;
  }

}