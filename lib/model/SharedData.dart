

import 'package:CryingBaby/model/Advices.dart';
import 'package:CryingBaby/model/Attendance.dart';
import 'package:CryingBaby/model/Child.dart';
import 'package:CryingBaby/model/ChildVaccines.dart';
import 'package:CryingBaby/model/Company.dart';
import 'package:CryingBaby/model/Messages.dart';
import 'package:CryingBaby/model/User.dart';
import 'package:CryingBaby/model/Vaccine.dart';
import 'package:CryingBaby/model/WorkingHour.dart';

import 'Employer.dart';

class SharedData {
  static Employer user = Employer.empty();
  static final String API_URL = "https://shamelg1.com/attendance/api";
  static final String IMAGE_URL = "https://shamelg1.com/attendance";
  static final String DEFAULT_IMAGE_URL = "https://shamelg1.com/attendance/images/avatar.png";

  static bool  first = false;

  static List<Attendance> attendance = [];

  static int type = -1;

  static Company currentCompany = Company.empty();

  static bool statics_loaded = false;

  static bool orders_loaded = false;

  static List<WorkingHour> workingHours =[];

  static Vaccine vaccine = Vaccine(day: "", description: "", name: "");

  static Messages message = Messages(description: "", title: "");

  static Advices advice = Advices(description: "", title: "", image: "");

  static User currentUser = User(name: "name", email: "email", password: "password");

  static Child child = Child(name: "name", birth_date: "birth_date", userKey: "userKey", sexType: "sexType");

  static int userType = 1;

  static Child currentChild = Child(name: "name", birth_date: "birth_date", userKey: "userKey", sexType: "sexType");

  static bool child_saved = false;

  static ChildVaccines currentVaccine = ChildVaccines(childKey: 'childKey', vaccine: 'vaccine', date: 'date', state: 0, image: 'image');
}