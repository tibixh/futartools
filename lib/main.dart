import 'dart:async';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:futartools/Theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:futartools/Pages/MapPage.dart';


void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  static Future<bool>getLocationPermission()async{
    var _permissionStatus = await Permission.locationWhenInUse.request();
    if(_permissionStatus.isGranted){
      return true;
    }else{
      return false;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FutarTools',
      themeMode: ThemeMode.dark,
      darkTheme: myTheme,
      home: FutureBuilder(
        future: getLocationPermission(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return mapPage();
          }else{
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator()
              ),
            );
          }
        }
      )
    );
  }
}


