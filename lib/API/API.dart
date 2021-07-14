import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class API{
  static var vehicles = <Vehicle>[];

  static Future<List<Vehicle>> getVehicles(bool downloadNew)async{
    if (downloadNew){
      http.Response response = await http.get(Uri.parse('https://futar.bkk.hu/api/query/v1/ws/otp/api/where/vehicles-for-location.json?version=3&appVersion=1&lon=47.468693&lat=19.068402&radius=200&query='));
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

  static Future<Response> getVehicle(String vehicleId) async{
    http.Response response = await http.get(Uri.parse("https://futar.bkk.hu/api/query/v1/ws/otp/api/where/trip-details.json?key=&version=3&appVersion=1&includeReferences=false&tripId=&vehicleId=" + vehicleId + "&date="));
    if(response.statusCode == 200){
      String res = utf8.decode(response.bodyBytes);
      Map<String,dynamic> json = jsonDecode(res);
      Map<String,dynamic> jsonvehicle = json['data']['entry']['vehicle'];

      Vehicle vehicle = Vehicle(jsonvehicle['vehicleId'],jsonvehicle['model'],jsonvehicle['label'],jsonvehicle['routeId'],jsonvehicle['deviated'],jsonvehicle['licensePlate']);

      return Response(response.statusCode, vehicle, null);
    }else{
      return Response(response.statusCode, null, null);
    }
  }

  static Future<Response> getRoute(String routeId) async{
    http.Response response = await http.get(Uri.parse("https://futar.bkk.hu/api/query/v1/ws/otp/api/where/route-details.json?key=&version=3&appVersion=1&includeReferences=false&routeId=" + routeId + "&related="));
    if(response.statusCode == 200){
      String res = utf8.decode(response.bodyBytes);
      Map<String,dynamic> json = jsonDecode(res);
      Map<String,dynamic> jsonroute = json['data']['entry'];

      Color color = hexToColor("#" + jsonroute['color']);
      Color textColor = hexToColor("#" + jsonroute['textColor']);
      Routee route =  Routee(jsonroute['id'],jsonroute['shortName'],jsonroute['description'],color,textColor);

      return Response(response.statusCode, null, route);
    }
    else{
      return Response(response.statusCode, null, null);
    }

  }



  static  hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

}

class Response{
  int? statusCode;
  Vehicle? vehicle;
  Routee? route;

  Response(this.statusCode,this.vehicle,this.route);
}

class Vehicle{
  String? vehicleId;
  String? model;
  String? label;
  String? routeId;
  bool? deviated;
  String? licensePlate;

  Vehicle(this.vehicleId, this.model, this.label, this.routeId,this.deviated,this.licensePlate);
}

class Routee{
  String? routeId;
  String? shortName;
  String? description;
  Color? color;
  Color? textColor;

  Routee(this.routeId,this.shortName,this.description,this.color,this.textColor);
}


