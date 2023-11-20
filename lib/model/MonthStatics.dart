
class MonthStatics {
  late String totalMonthDays = "0";
  late String totalAttendDays = "0";
  late String totalAbsenceDays = "0";
  late String totalDelayHours ="0";
  late String totalGoout = "0";
  late String totalHolidays = "0";
  late String totalFingers = "0";

  MonthStatics.empty();

  MonthStatics(this.totalMonthDays,this.totalAttendDays,this.totalAbsenceDays,this.totalDelayHours,this.totalGoout,this.totalHolidays,this.totalFingers);


  MonthStatics.fromJson(Map<String,dynamic> json):
        totalGoout=json['totalGoout'],
        totalDelayHours=json['totalDelayHours'],
        totalAbsenceDays=json['totalAbsenceDays'],
        totalAttendDays=json['totalAttendDays'],
        totalMonthDays=json['totalMonthDays'],
        totalHolidays=json['totalHolidays'],
        totalFingers=json['totalFingers'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalGoout'] = this.totalGoout;
    data['totalAbsenceDays'] = this.totalAbsenceDays;
    data['totalAttendDays'] = this.totalAttendDays;
    data['totalMonthDays'] = this.totalMonthDays;
    data['totalHolidays'] = this.totalHolidays;
    data['totalFingers'] = this.totalFingers;

    return data;
  }

}