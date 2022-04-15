// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:location/location.dart';

// import 'package:location/location.dart';
// import 'package:syncfusion_flutter_maps/maps.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "L I N U S",
      home: Maps(),
    ),
  );
}

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String url =
      "https://api.thingspeak.com/channels/959657/feeds.json?api_key=54NRPUVRXDB5AWTF&results=1";
  final String url2 =
      "https://api.thingspeak.com/channels/1411131/feeds.json?api_key=VPF9WGH2BOQ9H8XB&results=1";

  List data, data2, data3, data4;
  double latitude, longitude, latitude2, longitude2;
  Timer timer;

  double userClickLat, userClickLong;
  double usuLat = 3.5621649;
  double usuLong = 98.6564072;

  Position curpos;
  bool routesToBus = false;
  bool routesUserClick = false;
  int selectedRoutes = 0;

  int estimateBus1 = 0;
  int estimateBus2 = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      const oneSecond = Duration(seconds: 3);
      Timer.periodic(oneSecond, (Timer t) => setState(() {}));
    });

    getJsonData();
    _getCurrentLocation();
  }

  getCurrentPosition() async {
    curpos = await Geolocator.getCurrentPosition();
    print("Current position user : ${curpos.latitude},${curpos.longitude}");
  }

  Future<String> getJsonData() async {
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    var response2 = await http
        .get(Uri.parse(url2), headers: {"Accept": "application/json"});

    print(response2.body);

    var convertDataToJson = json.decode(response.body);
    var convertDataToJson2 = json.decode(response2.body);
    data = await convertDataToJson['feeds'];
    data2 = await convertDataToJson['feeds'];
    data3 = await convertDataToJson2['feeds'];
    data4 = await convertDataToJson2['feeds'];
    latitude = double.parse(data[0]['field1'].toString());
    longitude = double.parse(data2[0]['field2'].toString());
    latitude2 = double.parse(data3[0]['field1'].toString());
    longitude2 = double.parse(data4[0]['field2'].toString());
    userClickLat = latitude2;
    userClickLong = longitude2;
    print("latitude = $latitude");
    print("longitude = $longitude");
    print("latitude2 = $latitude2");
    print("longitude2 = $longitude2");

    setState(() {
    });

    return "Success";
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    getCurrentPosition();
    getJsonData();
    return Scaffold(
      appBar: AppBar(
        title: Text("L I N U S"),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.orangeAccent,
            onPressed: () {
              setState(() {
                routesToBus = !routesToBus;
              });
            },
            child: Icon(Icons.bus_alert),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            backgroundColor: Colors.orangeAccent,
            onPressed: () {
              setState(() {
                routesUserClick = !routesUserClick;
              });
            },
            child: Icon(Icons.accessibility_new_sharp),
          ),
        ],
      ),
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: (latitude == null || latitude2 == null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    child: Image(
                      image: AssetImage("images/BUS-USU.jpg"),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CircularProgressIndicator(
                      strokeWidth: 17,
                      backgroundColor: Colors.green,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                        center: latlng.LatLng(usuLat, usuLong),
                        zoom: 15.85,
                        onTap: (tapPosition, latLng) {
                          userClickLat = latLng.latitude;
                          userClickLong = latLng.longitude;
                        },
                        plugins: [
                          TappablePolylineMapPlugin(),
                        ]),
                    layers: [
                      TappablePolylineLayerOptions(
                          // Will only render visible polylines, increasing performance
                          polylineCulling: true,
                          polylines: [
                            if (routesToBus)
                              TaggedPolyline(
                                  tag: 'user click',
                                  strokeWidth: 4.0,
                                  color: Colors.orange,
                                  points: [
                                    latlng.LatLng(latitude2, longitude2),
                                    latlng.LatLng(
                                        curpos.latitude, curpos.longitude),
                                    latlng.LatLng(latitude, longitude),
                                  ]),
                            if (routesUserClick)
                              TaggedPolyline(
                                  tag: 'Route Bus',
                                  strokeWidth: 4.0,
                                  color: Colors.red,
                                  points: [
                                    latlng.LatLng(userClickLat, userClickLong),
                                    latlng.LatLng(
                                        curpos.latitude, curpos.longitude),
                                  ]),
                            TaggedPolyline(
                                tag: 'routes',
                                strokeWidth: 8.0,
                                isDotted: true,
                                color: selectedRoutes == 0
                                    ? Colors.green
                                    : Colors.black,
                                points: [
                                  latlng.LatLng(3.567344, 98.653182),
                                  latlng.LatLng(3.556379, 98.652847),
                                  latlng.LatLng(3.556342, 98.660556),
                                  latlng.LatLng(3.567140, 98.660153),
                                ]),
                          ],
                          onTap: (polylines, tapPosition) {
                            setState(() {
                              String tagSelected;
                              print('Tapped: ' +
                                  polylines
                                      .map((polyline) =>
                                          tagSelected = polyline.tag)
                                      .join(',') +
                                  ' at ' +
                                  tapPosition.globalPosition.toString());
                            });
                          },
                          onMiss: (tapPosition) {
                            userClickLat = curpos.latitude;
                            userClickLong = curpos.longitude;
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Bukan jalur bus"),
                            ));
                          })
                    ],
                    children: <Widget>[
                      TileLayerWidget(
                          options: TileLayerOptions(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c'])),
                      MarkerLayerWidget(
                        options: MarkerLayerOptions(
                          markers: [
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 25,
                              height: 25,
                              point: latlng.LatLng(latitude, longitude),
                              builder: (ctx) => Icon(
                                Icons.bus_alert,
                                size: 45,
                                color: Colors.green[900],
                              ),
                            ),
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 25,
                              height: 25,
                              point: latlng.LatLng(latitude2, longitude2),
                              builder: (ctx) => Icon(
                                Icons.bus_alert,
                                size: 45,
                                color: Colors.orange[900],
                              ),
                            ),
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 25,
                              height: 25,
                              point: latlng.LatLng(
                                  curpos.latitude, curpos.longitude),
                              builder: (ctx) => Icon(
                                Icons.accessibility_new_sharp,
                                size: 45,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 10,right: 10,bottom: 30),
                      height: 90,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (routesUserClick)
                            Text(
                              calculateDistance(curpos.latitude, curpos.longitude,
                                  userClickLat, userClickLong),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          if (routesToBus)
                            Text(
                              "Bus 1 = ${calculateDistance(curpos.latitude, curpos.longitude, latitude, longitude)}"
                                  " ($estimateBus1 Menit)",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          if (routesToBus)
                            Text(
                              "Bus 2 = ${calculateDistance(curpos.latitude, curpos.longitude, latitude2, longitude2)}"
                                  " ($estimateBus2 Menit)",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Rute bus",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String calculateDistance(lat1, lon1, lat2, lon2) {
    double distance =
        Geolocator.distanceBetween(lat1, lon1, lat2, lon2).ceilToDouble();

    estimateBus1 = distance~/(20000/60);
    estimateBus2 = distance~/(20000/60);
    if (distance >= 1000) {
      return '${distance / 1000} Kilometer';
    }
    return '$distance Meter';
  }
}
