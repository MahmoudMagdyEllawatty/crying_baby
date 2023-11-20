
class Question {
  String id;
  final String userName;
  final String question;
  String answer;
  final String date;

  Question({
  this.id = '',
  required this.userName,
  required this.question,
    required this.answer,
    required this.date
  });




  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['question'] = this.question;
    data['userName'] = this.userName;
    data['id'] = this.id;
    data['answer'] = this.answer;
    data['date'] = this.date;

    return data;
  }

  static Question fromJson(Map<String,dynamic> json) => Question(
      question : json['question'],
      id: json['id'],
      userName : json['userName'],
      answer: json['answer'],
  date: json['date']);
}