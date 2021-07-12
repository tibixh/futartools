import 'dart:async';
import 'package:futartools/API/API.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class mapPage extends StatefulWidget {
  const mapPage({Key? key}) : super(key: key);

  @override
  _mapPageState createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  @override

  var vehicles = <Vehicle>[];
  getVehicles(String query)async{
    List<Vehicle> _vehicles = await API.getVehicles(true);

    for(int i = 0;i < _vehicles.length;i++){
      if (_vehicles[i].model.contains(query)){
        vehicles.add(_vehicles[i]);
      }
    }
  }

  late String _mapStyle;
  @override
  void initState() {
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  static const defaultCameraPosition = CameraPosition(
      target: LatLng(47.468831,19.067455),
      zoom: 11.5
  );

  moveCameraToCurrentLocation()async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng location = LatLng(position.latitude,position.longitude);
    moveCameraToLocation(location);
  }

  moveCameraToLocation(LatLng location)async{
    CameraPosition cameraPosition = CameraPosition(target: location,zoom: 15);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  refresh(){
    setState(() {

    });
  }







  Widget build(BuildContext context) {
    return Scaffold(
        body: SlidingUpPanel(
          minHeight: 50,
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          panel: buildSlideUpPanel(),
          body: buildStack()
        )
    );
  }


  Widget buildStack(){
    return Stack(
      children: [
        buildGoogleMaps(),
        buildFloatingSearchBar(),
        buildButtons(),
      ],
    );
  }

  Widget buildGoogleMaps(){
    return GoogleMap(
      initialCameraPosition: defaultCameraPosition,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        controller.setMapStyle(_mapStyle);
      },
    );
  }

  Widget buildSlideUpPanel(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).backgroundColor,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(22.5),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: getVehicles("Ikarus"),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.done){
                return Container(
                  padding: EdgeInsets.only(top: 50),
                  child: ListView.builder(
                    itemCount: vehicles.length,
                    itemBuilder: (BuildContext context, int i){
                      return Container(
                        color: Theme.of(context).backgroundColor,
                        padding: const EdgeInsets.all(12.0),
                        child: Text(vehicles[i].model),
                      );
                    },
                  ),
                );
              }else{
                return CircularProgressIndicator();
              }
            }
          )
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(height: 112, color: color);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget buildButtons(){
    return Stack(
      children: [
        Positioned(
          bottom: 60,
          right: 10,
          child: FloatingActionButton(
            onPressed: moveCameraToCurrentLocation,
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).accentColor,
            child: Icon(
              Icons.my_location
            ),
          )
        ),
        Positioned(
            bottom: 130,
            right: 10,
            child: FloatingActionButton(
              onPressed: refresh,
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).accentColor,
              child: Icon(
                  Icons.refresh
              ),
            )
        )
      ],
    );
  }
}
