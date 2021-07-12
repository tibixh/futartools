import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class API{
  static var vehicles = <Vehicle>[];

  static Future<List<Vehicle>> getVehicles(bool downloadNew)async{
    if (downloadNew){
      http.Response response = await http.get(Uri.parse('https://futar.bkk.hu/api/query/v1/ws/otp/api/where/vehicles-for-location.json?key=&version=3&appVersion=1&includeReferences=false&lon=47.468693&lat=19.068402&latSpan=&lonSpan=&radius=200&query=&ifModifiedSince='));
      if (response.statusCode == 200){
        String res = utf8.decode(response.bodyBytes);
        Map<String,dynamic> json = jsonDecode(res);
        List<dynamic> jsonlist = (json['data']['list'] as List<dynamic>);

        vehicles.clear();

        for (int i = 0; i< jsonlist.length; i++){

          vehicles.add(Vehicle(jsonlist[i]['vehicleId'],jsonlist[i]['model'],jsonlist[i]['label'],jsonlist[i]['routeId'],jsonlist[i]['deviated'],jsonlist[i]['licensePlate']));
        }
      }
      return vehicles;
    }else{
      throw "Unknown error";
    }


  }

  static Future<Vehicle> getVehicle(String vehicleId) async{
    http.Response response = await http.get(Uri.parse("https://futar.bkk.hu/api/query/v1/ws/otp/api/where/trip-details.json?key=&version=3&appVersion=1&includeReferences=false&tripId=&vehicleId=" + vehicleId + "&date="));
    if(response.statusCode == 200){
      String res = utf8.decode(response.bodyBytes);
      Map<String,dynamic> json = jsonDecode(res);
      Map<String,dynamic> jsonvehicle = json['data']['entry']['vehicle'];

      return Vehicle(jsonvehicle['vehicleId'],jsonvehicle['model'],jsonvehicle['label'],jsonvehicle['routeId'],jsonvehicle['deviated'],jsonvehicle['licensePlate']);
    }else{
      throw response.statusCode;
    }
  }

  static Future<Routee> getRoute(String routeId) async{
    http.Response response = await http.get(Uri.parse("https://futar.bkk.hu/api/query/v1/ws/otp/api/where/route-details.json?key=&version=3&appVersion=1&includeReferences=false&routeId=" + routeId + "&related="));
    if(response.statusCode == 200){
      String res = utf8.decode(response.bodyBytes);
      Map<String,dynamic> json = jsonDecode(res);
      Map<String,dynamic> jsonroute = json['data']['entry'];

      Color color = hexToColor("#" + jsonroute['color']);
      Color textColor = hexToColor("#" + jsonroute['textColor']);
      return Routee(jsonroute['id'],jsonroute['shortName'],jsonroute['description'],color,textColor);
    }
    else{
      throw response.statusCode;
    }

  }



  static  hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

}

class Vehicle{
  String vehicleId;
  String model;
  String label;
  String routeId;
  bool deviated;
  String licensePlate;

  Vehicle(this.vehicleId, this.model, this.label, this.routeId,this.deviated,this.licensePlate);
}

class Routee{
  String routeId;
  String shortName;
  String description;
  Color color;
  Color textColor;

  Routee(this.routeId,this.shortName,this.description,this.color,this.textColor);
}


