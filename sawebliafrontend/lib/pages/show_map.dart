// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:map_launcher/map_launcher.dart' as ml;

import 'package:sawebliafrontend/models/Artisan.dart';
import 'package:sawebliafrontend/models/Mission.dart';
import 'package:sawebliafrontend/pages/mission_encours1.dart';
import 'package:sawebliafrontend/pages/uploadtocloud.dart';
import 'package:sawebliafrontend/services/artisanservice.dart';
import 'package:sawebliafrontend/services/authentificationservice.dart';
import 'package:sawebliafrontend/services/missionservice.dart';
import 'package:sawebliafrontend/services/smsservice.dart';
import 'package:sawebliafrontend/utils/MyColors.dart';
import 'package:sawebliafrontend/utils/artisanProvider.dart';
import 'package:sawebliafrontend/utils/location_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowMap extends StatefulWidget {
  final int missionId;

  const ShowMap({required this.missionId});

  @override
  State<ShowMap> createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final MissionService _missionService = MissionService();
  Mission? mission;
  LatLng? clientLocation = const LatLng(0, 0);

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Map<MarkerId, Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  Position? _latestPosition;
  // Position _latestPosition = Position(
  //   latitude: 0.0,
  //   longitude: 0.0,
  //   timestamp: DateTime.now(),
  //   accuracy: 0.0,
  //   altitude: 0.0,
  //   heading: 0.0,
  //   speed: 0.0,
  //   speedAccuracy: 0.0,
  // );
  late bool servicePermission;
  late LocationPermission permission;
  LatLng? _destinationCoordinates; // Destination coordinates
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "your_google_api_key";
  Map<PolylineId, Polyline> polylines = {};
  Artisan? currentArtisan;
  ArtisanProvider artisanProvider = ArtisanProvider();
  final LocationPermissionManager _locationPermissionManager =
      LocationPermissionManager();
  final AuthService _authService = AuthService();
  bool isCloseToDestination = false;

  @override
  void initState() {
    super.initState();
    initializeArtisan(context);
    initializeMap();

    print('mission id in show map : ${widget.missionId}');
    if (mounted) {
      setState(() {});
    }
  }

  void initializeArtisan(BuildContext context) async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final String savedEmail = _sharedPreferences.getString("emailkey") ?? "";
    final String savedPassword =
        _sharedPreferences.getString("passwordkey") ?? "";

    final Artisan? savedArtisan =
        await _authService.authenticate(savedEmail, savedPassword);
    if (mounted) {
      setState(() {
        currentArtisan = savedArtisan;
      });
    }
  }

  void initializeMap() async {
    _getClientLocation();
    final permissionGranted =
        await _locationPermissionManager.checkAndRequestPermission(context);
    print(permissionGranted);
    if (permissionGranted) {
      _latestPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _getCurrentLocation();
      _handleGetDirections();
      _checkDistanceToDestination();
    }
  }

  Future<void> _getClientLocation() async {
    Mission mymission = await _missionService.getMissionById(widget.missionId);
    mission = mymission;

    print(mymission.toJson());
    print(mymission.idMission);

    if (mission!.latitude != null && mission!.longitude != null) {
      clientLocation = LatLng(mission!.latitude!, mission!.longitude!);
      _destinationCoordinates = clientLocation;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Missing"),
            content: Text("Client location is not available."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    print("client location : $clientLocation");
    if (mounted) {
      setState(() {});
    }
  }

  void _checkDistanceToDestination() {
    if (_latestPosition != null && _destinationCoordinates != null) {
      double distanceToDestination = Geolocator.distanceBetween(
        _latestPosition!.latitude,
        _latestPosition!.longitude,
        _destinationCoordinates!.latitude,
        _destinationCoordinates!.longitude,
      );

      if (distanceToDestination <= 500 && distanceToDestination > 60) {
        isCloseToDestination = true;

        // Show a dialog here
        // showDialog<void>(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: const Text('Alert'),
        //       content: Text('Tél Client : ${mission?.telClient}'),
        //     );
        //   },
        // );
        if (mounted) {
          setState(() {});
        }
      }

      if (distanceToDestination <= 60) {
        //  ajouterBonus = true;

        // showDialog<void>(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: const Text('Alert'),
        //       content: Stack(children: [
        //         Align(
        //           alignment: Alignment.bottomRight,
        //           child: IconButton(
        //             icon: Icon(Icons.close),
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //           ),
        //         ),
        //         Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Text(
        //                 'Vous êtes presque arrivé, vous pouvez passer à la prochaine '),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             Text(
        //               'Tél Client : ${mission?.telClient}',
        //               style: TextStyle(fontWeight: FontWeight.bold),
        //             )
        //           ],
        //         ),
        //       ]),
        //     );
        //   },
        //);
        // setState(() {});
      }
    }
  }

  void _getCurrentLocation() async {
    print("_destinationCoordinates $_destinationCoordinates");
    const MarkerId markerId = MarkerId('currentLocation');

// INITIALIZING WITH CURRENT POSITION
    _latestPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _checkDistanceToDestination();
      });
    }
    ();
    _markers[markerId] = Marker(
      markerId: markerId,
      position: LatLng(_latestPosition!.latitude, _latestPosition!.longitude),
      infoWindow: const InfoWindow(title: 'موقعي الحالي'),
    );

    // WHEN POSITION CHANGES

    polylines.clear();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ), // Update every 10 meters
    ).listen((position) {
      _latestPosition = position;
      if (mounted) {
        setState(() {
          _checkDistanceToDestination();
        });
      }
      print("_latestPosition ==== $_latestPosition  , position === $position");
      _markers.clear();
      _markers[markerId] = Marker(
        markerId: markerId,
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
      );
    });
    // } else {
    //   print('Permission is not granted');
    //   showDialog<void>(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return const AlertDialog(
    //         title: Text('Une erreurs s\'est produite'),
    //         content: Text('Erreur de chargement de la carte'),
    //       );
    //     },
    //   );
    // }
  }

  void _handleGetDirections() async {
    _getCurrentLocation();
    if (_latestPosition != null && _destinationCoordinates != null) {
      try {
        List<LatLng> polylineCoordinates = [];
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPiKey,
          PointLatLng(_latestPosition!.latitude, _latestPosition!.longitude),
          PointLatLng(
            _destinationCoordinates!.latitude,
            _destinationCoordinates!.longitude,
          ),
          travelMode: TravelMode.walking,
        );

        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
          addPolyLine(polylineCoordinates);
        } else {
          print('No polyline points available');
        }
      } catch (e) {
        print('Error getting directions: $e');
      }
    } else {
      print('Current position or destination coordinates not available.');
    }
    if (mounted) {
      setState(() {});
    }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue[800]!,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  double calculateDistance() {
    double distance = Geolocator.distanceBetween(
      _latestPosition!.latitude,
      _latestPosition!.longitude,
      _destinationCoordinates!.latitude,
      _destinationCoordinates!.longitude,
    );
    return distance;
  }

  @override
  void didUpdateWidget(ShowMap oldWidget) {
    if (widget.missionId != oldWidget.missionId) {
      initializeMap();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print(
        "_latestPosition : $_latestPosition , _destinationCoordinates : $_destinationCoordinates");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkblue1,
        title: Text("خريطة"),
      ),
      body: _latestPosition == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _latestPosition!.latitude,
                      _latestPosition!.longitude,
                    ),
                    zoom: 15.0,
                  ),
                  markers: Set<Marker>.of([
                    ..._markers.values,
                    if (_destinationCoordinates != null)
                      Marker(
                        markerId: const MarkerId('موقع الكليان'),
                        position: _destinationCoordinates!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        infoWindow: const InfoWindow(title: 'موقع الكليان'),
                      ),
                  ]),
                  polylines: Set<Polyline>.of(polylines.values),
                  mapType: MapType.normal,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      refreshPageButton(),
                      openInMapButton(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Widget refreshPageButton() {
    return ElevatedButton(
      onPressed: () {
        _handleGetDirections();
        print('Distance to Destination: ${calculateDistance()} meters');
        if (mounted) {
          setState(() {});
        }
      },
      style: ElevatedButton.styleFrom(
        primary: MyColors.darkblue1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh_rounded),
          SizedBox(
            width: 5,
          ),
          Text(
            'تحديث الصفحة',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget openInMapButton() {
    return ElevatedButton(
      onPressed: () async {
        _openMapsSheet(context);
      },
      style: ElevatedButton.styleFrom(
        primary: MyColors.darkblue1,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map),
          SizedBox(width: 5),
          Text(
            'مشاهدة على Google Maps/Waze',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  _openMapsSheet(context) async {
    try {
      if (_destinationCoordinates?.latitude != null &&
          _destinationCoordinates?.longitude != null) {
        final coords = ml.Coords(_destinationCoordinates!.latitude,
            _destinationCoordinates!.longitude);
        final title = "${mission?.adresse}";
        final availableMaps = await ml.MapLauncher.installedMaps;

        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Wrap(
                    children: <Widget>[
                      for (var map in availableMaps)
                        ListTile(
                          onTap: () {
                            map.showMarker(
                              coords: coords,
                              title: title,
                            );
                            map.showDirections(
                              destination: coords,
                              directionsMode: ml.DirectionsMode.driving,
                            );
                          },
                          title: Text(map.mapName),
                          leading: SvgPicture.asset(
                            map.icon,
                            height: 30.0,
                            width: 30.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print("Error accured in show Map : $e");
    }
  }
}
