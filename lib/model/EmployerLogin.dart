
import 'dart:convert';

import 'Employer.dart';


class EmployerLogin {
  late String msg;
  late int code;
  late Employer? user;

  EmployerLogin.empty();

  EmployerLogin(this.msg,this.code,this.user);

  factory EmployerLogin.fromMap(Map<String,dynamic> data){

    if(data['user'] != null){
      var uu = jsonEncode(data['user']);
      final parsed = json.decode(uu);

      Map<String,dynamic> employerMap = jsonDecode(uu);

      return EmployerLogin(
          data['msg'] as String,
          data['code'] as int,
          Employer.fromJson(employerMap)
      );
    }else{

      return EmployerLogin(
          data['msg'] as String,
          data['code'] as int,
          data['user']
      );
    }

  }




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['code'] = this.code;
    data['user'] = this.user;
    return data;
  }

}