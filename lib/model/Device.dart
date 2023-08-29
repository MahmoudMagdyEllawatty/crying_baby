
class Device {
  late String name;
  late String device_mac;

  Device.empty();

  Device(this.name,this.device_mac);


  Device.fromJson(Map<String,dynamic> json): device_mac=json['device_mac'],name=json['name'];

  Map<String,dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['device_mac'] = this.device_mac;
    return data;
  }

}