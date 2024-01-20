import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  String city;
  final String latitude;
  final String longitude;
  String? temp;
  String? windSpeed;
  String? humidity;
  String? cloud;
  String? pressure;
  String? destription;
  String? main;
  String? icon;

  WeatherData(
      {required this.city, required this.latitude, required this.longitude});

  Future<void> fetchData() async {
    if (city == '') {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=f46448491b834d6a63a0c43bf2b269a0'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String getTemp = data['main']['temp'].toString();
        String getDescription = (data['weather'] as List<dynamic>?)
                ?.first['description']
                ?.toString() ??
            'N/A';
        String getIcon =
            (data['weather'] as List<dynamic>?)?.first['icon']?.toString() ??
                'N/A';
        String getPressure = data['main']['pressure'].toString();
        String getWindspeed = data['wind']['speed'].toString();
        String getHumidity = data['main']['humidity'].toString();
        String getCloud = data['clouds']['all'].toString();
        String currentCity = data['name'].toString();
//assigning the values
        temp = getTemp;
        pressure = getPressure;
        windSpeed = getWindspeed;
        cloud = getCloud;
        humidity = getHumidity;
        city = currentCity;
        destription = getDescription;
        icon = getIcon;
      } else {
        // Handle error cases
        print('Failed to fetch data: ${response.statusCode}');
      }
    } else {
      print('this is the else case');
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeQueryComponent(city)}&appid=f46448491b834d6a63a0c43bf2b269a0'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String getTemp = data['main']['temp'].toString();
        String getPressure = data['main']['pressure'].toString();
        String getDescription = (data['weather'] as List<dynamic>?)
                ?.first['description']
                ?.toString() ??
            'N/A';
        String getIcon =
            (data['weather'] as List<dynamic>?)?.first['icon']?.toString() ??
                'N/A';
        String getWindspeed = data['wind']['speed'].toString();
        String getHumidity = data['main']['humidity'].toString();
        String getCloud = data['clouds']['all'].toString();
        String currentCity = data['name'].toString();
//assigning the values
        temp = getTemp;
        pressure = getPressure;
        windSpeed = getWindspeed;
        cloud = getCloud;
        humidity = getHumidity;
        city = currentCity;
        destription = getDescription;
        icon = getIcon;
      } else {
        // Handle error cases
        print('Failed to fetch data: ${response.statusCode}');
      }
    }
  }
}