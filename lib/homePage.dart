import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:weather_tutorial/dataset.dart';
import 'package:weather_tutorial/detailPage.dart';
import 'package:weather_tutorial/extraWeather.dart';

Weather currentTemp;
Weather tomorrowTemp;
List<Weather> todayWeather;
List<Weather> sevenDay;
String lat = "53.9006";
String lon = "27.5590";
String city = "Minisk";
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  getData() async{
    fetchData(lat, lon, city).then((value){
      currentTemp = value[0];
      todayWeather = value[1];
      tomorrowTemp = value[2];
      sevenDay = value[3];
      setState(() {
        
      });
    });
  }

@override
void initState() { 
  super.initState();
  getData();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff030317),
      body: currentTemp==null ? Center(child: CircularProgressIndicator(),):Column(
        children: [CurrentWeather(getData), TodayWeather()],
      ),
    );
  }
}

class CurrentWeather extends StatefulWidget {
  final Function() updateData;
  CurrentWeather(this.updateData);
  @override
  _CurrentWeatherState createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {

bool searchBar = false;
bool updating = false;
var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(searchBar)
        setState(() {
          searchBar = false;
        });
      },
      child: GlowContainer(
        height: MediaQuery.of(context).size.height - 230,
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.only(top: 50, left: 30, right: 30),
        glowColor: Color(0xff00A1FF).withOpacity(0.5),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
        color: Color(0xff00A1FF),
        spreadRadius: 5,
        child: Column(
          children: [
            Container(
              child: searchBar?
              TextField(
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Color(0xff030317),
                  filled: true,
                  hintText:"Enter a city Name"
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value)async{
                  CityModel temp = await fetchCity(value);
                  if(temp==null){
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        backgroundColor: Color(0xff030317),
                        title:Text("City not found"),
                        content: Text("Please check the city name"),
                        actions: [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: Text("Ok"))
                        ],
                      );
                    });
                    searchBar = false;
                    return;
                  }
                  city = temp.name;
                  lat = temp.lat;
                  lon = temp.lon;
                  updating = true;
                  setState(() {
                    
                  });
                  widget.updateData();
                  searchBar = false;
                  updating = false;
                  setState(() {
                    
                  });
                },
              )
              :Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    CupertinoIcons.square_grid_2x2,
                    color: Colors.white,
                  ),
                  Row(
                    children: [
                      Icon(CupertinoIcons.map_fill, color: Colors.white),
                      GestureDetector(
                        onTap: (){
                          searchBar = true;
                          setState(() {
                            
                          });
                          focusNode.requestFocus();
                        },
                        child: Text(
                          " " + city,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.more_vert, color: Colors.white)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.2, color: Colors.white),
                  borderRadius: BorderRadius.circular(30)),
              child: Text(
                updating?"Updating":"Updated",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 430,
              child: Stack(
                children: [
                  Image(
                    image: AssetImage(currentTemp.image),
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Center(
                        child: Column(
                      children: [
                        GlowText(
                          currentTemp.current.toString(),
                          style: TextStyle(
                              height: 0.1,
                              fontSize: 150,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(currentTemp.name,
                            style: TextStyle(
                              fontSize: 25,
                            )),
                        Text(currentTemp.day,
                            style: TextStyle(
                              fontSize: 18,
                            ))
                      ],
                    )),
                  )
                ],
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            SizedBox(
              height: 10,
            ),
            ExtraWeather(currentTemp)
          ],
        ),
      ),
    );
  }
}

class TodayWeather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return DetailPage(tomorrowTemp,sevenDay);
                  }));
                },
                child: Row(
                  children: [
                    Text(
                      "7 days ",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.grey,
                      size: 15,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 30,
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherWidget(todayWeather[0]),
                  WeatherWidget(todayWeather[1]),
                  WeatherWidget(todayWeather[2]),
                  WeatherWidget(todayWeather[3])
                ]),
          )
        ],
      ),
    );
  }
}

class WeatherWidget extends StatelessWidget {
  final Weather weather;
  WeatherWidget(this.weather);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(width: 0.2, color: Colors.white),
          borderRadius: BorderRadius.circular(35)),
      child: Column(
        children: [
          Text(
            weather.current.toString() + "\u00B0",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 5,
          ),
          Image(
            image: AssetImage(weather.image),
            width: 50,
            height: 50,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            weather.time,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
