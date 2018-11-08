/* File to get location of user
* used dependencies - location => to get location coordinates of user,
*   - geoLocation => To get Address from the location coordinates
 */
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

getUserLocation() async {
  Map<String, double> currentLocation = new Map();
  Map<String, double> myLocation;
  String error;
  Location location = new Location();
  try {
    myLocation = await location.getLocation();
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = 'please grant permission';
      print(error);
    }
    if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
      error = 'permission denied- please enable it from app settings';
      print(error);
    }
    myLocation = null;
  }
  currentLocation = myLocation;
  final coordinates = new Coordinates(
      currentLocation['latitude'], currentLocation['longitude']);
  var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  return first;
}
