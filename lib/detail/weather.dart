// ignore_for_file: sort_child_properties_last


import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_theme/model/weather_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_icons/weather_icons.dart';

class weatherdata extends StatefulWidget {
  weatherdata({super.key});

  @override
  State<weatherdata> createState() => _weatherdataState();
}

class _weatherdataState extends State<weatherdata> {
  var cityController = TextEditingController();
  var isloading = true;
  String temp = 'N/A';
  String windSpeed = 'N/A';
  String humidity = 'N/A';
  String cloud = 'N/A';
  String pressure = 'N/A';
  String destription = 'N/A';
  String main = 'N/A';
  String city = 'N/A';
  String icon = 'N/A';

  void _getCurrentLocation() async {
    try {
      var status = await Permission.location.request();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      if (status == PermissionStatus.granted) {
        setState(() {
          isloading = true;
        });
        WeatherData instance = WeatherData(
            city: cityController.text,
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString());
        await instance.fetchData();
        setState(() {
          isloading = false;
          temp = instance.temp.toString();
          destription = instance.destription.toString();
          cloud = instance.cloud.toString();
          city = instance.city.toString();
          icon = instance.icon.toString();
          pressure = instance.pressure.toString();
          humidity = instance.humidity.toString();
          windSpeed = instance.humidity.toString();
          cityController.text = '';
        });
      }
      print(humidity);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: isloading
            ? Center(child: const CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black12,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(
                                Icons.search,
                                size: 35,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextField(
                                controller: cityController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search Anything...',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 45,
                                  width: 50,
                                  child: Image.network(
                                    'https://openweathermap.org/img/wn/$icon@2x.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '$destription in $city',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 217, 133, 210),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 175,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 81, 167, 237),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Temperature',
                                style:
                                    TextStyle(fontSize: 23, color: Colors.red),
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    WeatherIcons.thermometer,
                                    size: 35,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(double.parse(temp) - 273.15).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 35, color: Colors.white),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    WeatherIcons.celsius,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    "Humidity",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  const Icon(
                                    WeatherIcons.humidity,
                                    size: 50,
                                  ),
                                  Text(
                                    '$humidity %',
                                    style: const TextStyle(
                                        fontSize: 23, color: Colors.white),
                                  )
                                ],
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 81, 167, 237),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'Pressure',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red),
                                  ),
                                  const Icon(
                                    WeatherIcons.barometer,
                                    size: 50,
                                  ),
                                  Text(
                                    '$pressure Atm',
                                    style: const TextStyle(
                                        fontSize: 23, color: Colors.white),
                                  ),
                                ],
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 81, 167, 237),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 81, 167, 237),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Wind Speed is $windSpeed Km/hr',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}