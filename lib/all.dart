// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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
  final String url =
      "https://api.thingspeak.com/channels/959657/feeds.json?api_key=54NRPUVRXDB5AWTF&results=1";
  final String url2 =
      "https://api.thingspeak.com/channels/1411131/feeds.json?api_key=VPF9WGH2BOQ9H8XB&results=1";

   List data, data2, data3, data4;
   double curlat, curlong, latitude, longitude, latitude2, longitude2;
   Timer timer;

   Position curpos;

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

  Future<String> getJsonData() async {
    var response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    print(response.body);

    var response2 = await http
        .get(Uri.parse(url2), headers: {"Accept": "application/json"});

    print(response2.body);

    setState(() {
      var convertDataToJson = json.decode(response.body);
      var convertDataToJson2 = json.decode(response2.body);
      data = convertDataToJson['feeds'];
      data2 = convertDataToJson['feeds'];
      data3 = convertDataToJson2['feeds'];
      data4 = convertDataToJson2['feeds'];
      latitude = double.parse(data[0]['field1'].toString());
      longitude = double.parse(data2[0]['field2'].toString());
      latitude2 = double.parse(data3[0]['field1'].toString());
      longitude2 = double.parse(data4[0]['field2'].toString());
      print("latitude = $latitude");
      print("longitude = $longitude");
      print("latitude2 = $latitude2");
      print("longitude2 = $longitude2");

      curlat = double.parse(curpos.latitude.toString());
      curlong = double.parse(curpos.longitude.toString());
      print("curlat = $curlat");
      print("curlong = $curlong");
    });

    return "Success";
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        curpos = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: (data4 == null)
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
          : FlutterMap(
              options: MapOptions(
                center: latlng.LatLng(3.5621649, 98.6564072),
                zoom: 15.75,
              ),
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
                        point: latlng.LatLng(curlat, curlong),
                        builder: (ctx) => Icon(
                          Icons.location_pin,
                          size: 45,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
