import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:herodriver/pages/language/languages.dart';
import 'package:herodriver/pages/loadingPage/loading.dart';
import 'package:herodriver/pages/onTripPage/map_page.dart';
import 'package:herodriver/pages/noInternet/nointernet.dart';
import 'package:herodriver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:herodriver/pages/vehicleInformations/upload_docs.dart';
import 'package:herodriver/translation/translation.dart';
import 'package:herodriver/widgets/widgets.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geolocator;
import '../login/signupmethod.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

dynamic package;

class _LoadingPageState extends State<LoadingPage> {
  String dot = '.';
  bool updateAvailable = false;
  late geolocator.LocationPermission permission;
  String state = '';
  int gettingPerm = 0;
  dynamic _version;
  bool _isLoading = false;

  var demopage = TextEditingController();

  //navigate
  navigate() {
    if (userDetails['uploaded_document'] == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Docs()));
    } else if (userDetails['uploaded_document'] == true &&
        userDetails['approve'] == false) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DocsProcess(),
          ));
    } else if (userDetails['uploaded_document'] == true &&
        userDetails['approve'] == true) {
      //status approved
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Maps()),
          (route) => false);
    }
  }

  @override
  void initState() {
    getLanguageDone();

    super.initState();
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
    permission = await geolocator.GeolocatorPlatform.instance.checkPermission();
    serviceEnabled =
        await geolocator.GeolocatorPlatform.instance.isLocationServiceEnabled();

    if ((permission == geolocator.LocationPermission.denied ||
            permission == geolocator.LocationPermission.deniedForever ||
            serviceEnabled == false) &&
        gettingPerm == 0) {
      gettingPerm++;
      await Future.delayed(const Duration(seconds: 5), () {});
      if (gettingPerm > 1) {
        locationAllowed = false;
        state = '3';
      } else {
        state = '2';
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      if (permission == geolocator.LocationPermission.whileInUse ||
          permission == geolocator.LocationPermission.always) {
        if (center == null) {
          var locs = await geolocator.Geolocator.getLastKnownPosition();
          if (locs != null) {
            center = LatLng(locs.latitude, locs.longitude);
          } else {
            var loc = await geolocator.Geolocator.getCurrentPosition(
                desiredAccuracy: geolocator.LocationAccuracy.low);
            center = LatLng(double.parse(loc.latitude.toString()),
                double.parse(loc.longitude.toString()));
          }
        }
        positionStreamData();
      }
      package = await PackageInfo.fromPlatform();
      // if (platform == Platform.isAndroid) {
      //   _version = await FirebaseDatabase.instance
      //       .ref()
      //       .child('driver_android_version')
      //       .get();
      // } else {
      //   _version = await FirebaseDatabase.instance
      //       .ref()
      //       .child('driver_ios_version')
      //       .get();
      // }
      // if (_version.value != null) {
      //   var version = _version.value.toString().split('.');
      //   var packages = package.version.toString().split('.');
      //
      //   for (var i = 0; i < version.length || i < packages.length; i++) {
      //     if (i < version.length && i < packages.length) {
      //       if (int.parse(packages[i]) < int.parse(version[i])) {
      //         setState(() {
      //           updateAvailable = true;
      //         });
      //         break;
      //       } else if (int.parse(packages[i]) > int.parse(version[i])) {
      //         setState(() {
      //           updateAvailable = false;
      //         });
      //         break;
      //       }
      //     } else if (i >= version.length && i < packages.length) {
      //       setState(() {
      //         updateAvailable = false;
      //       });
      //       break;
      //     } else if (i < version.length && i >= packages.length) {
      //       setState(() {
      //         updateAvailable = true;
      //       });
      //       break;
      //     }
      //   }
      // }

      if (updateAvailable == false) {
        await getDetailsOfDevice();
        if (internet == true) {
          var val = await getLocalData();

          //if user is login and check waiting for approval status and send accordingly
          if (val == '3') {
            navigate();
          }
          //if user is not login in this device
          else if (val == '2') {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignupMethod()));
            });
          } else {
            //user installing first time and didnt yet choosen language
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Languages()));
            });
          }
        } else {
          setState(() {});
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  getLocationPermission() async {
    if (serviceEnabled == false) {
      // await location.requestService();
      await geolocator.Geolocator.getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.low);
    }
    if (await geolocator.GeolocatorPlatform.instance
        .isLocationServiceEnabled()) {
      if (permission == geolocator.LocationPermission.denied ||
          permission == geolocator.LocationPermission.deniedForever) {
        if (permission != geolocator.LocationPermission.deniedForever &&
            await geolocator.GeolocatorPlatform.instance
                .isLocationServiceEnabled()) {
          if (platform == Platform.isAndroid) {
            await perm.Permission.location.request();
            await perm.Permission.locationAlways.request();
          } else {
            await [perm.Permission.location].request();
          }
        }
      }
    }
    setState(() {
      _isLoading = true;
    });
    getLanguageDone();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            (state == '2')
                ? Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: media.height * 0.31,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Text(
                          (choosenLanguage != '')
                              ? languages[choosenLanguage]['text_trustedtaxi']
                              : 'Most Trusted Taxi Booking App',
                          style: GoogleFonts.roboto(
                              fontSize: media.width * eighteen,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Text(
                          (choosenLanguage != '')
                              ? languages[choosenLanguage]
                                  ['text_allowpermission1']
                              : 'To enjoy your ride experience',
                          style: GoogleFonts.roboto(
                            fontSize: media.width * fourteen,
                          ),
                        ),
                        Text(
                          (choosenLanguage != '')
                              ? languages[choosenLanguage]
                                  ['text_allowpermission2']
                              : 'Please allow us the following permissions',
                          style: GoogleFonts.roboto(
                            fontSize: media.width * fourteen,
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              media.width * 0.05, 0, media.width * 0.05, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: media.width * 0.075,
                                  child:
                                      const Icon(Icons.location_on_outlined)),
                              SizedBox(
                                width: media.width * 0.025,
                              ),
                              SizedBox(
                                width: media.width * 0.8,
                                child: Text(
                                  (choosenLanguage != '')
                                      ? languages[choosenLanguage]
                                          ['text_loc_permission']
                                      : 'Allow Location all the time - To book a taxi',
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.02,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              media.width * 0.05, 0, media.width * 0.05, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: media.width * 0.075,
                                  child:
                                      const Icon(Icons.location_on_outlined)),
                              SizedBox(
                                width: media.width * 0.025,
                              ),
                              SizedBox(
                                width: media.width * 0.8,
                                child: Text(
                                  (choosenLanguage != '')
                                      ? languages[choosenLanguage]
                                          ['text_background_permission']
                                      : 'Enable Background Location - collects location data to enable users to identify nearby drivers even when the app is closed or not in use',
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.all(media.width * 0.05),
                            child: Button(
                                onTap: () async {
                                  getLocationPermission();
                                },
                                text: (choosenLanguage != '')
                                    ? languages[choosenLanguage]
                                        ['text_continue']
                                    : 'Continue'))
                      ],
                    ),
                  )
                : Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    decoration: BoxDecoration(
                      color: buttonColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(media.width * 0.01),
                          width: media.width * 0.429,
                          height: media.width * 0.429,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/logo.png'),
                                  fit: BoxFit.contain)),
                        ),
                      ],
                    ),
                  ),

            //update available

            (updateAvailable == true)
                ? Positioned(
                    top: 0,
                    child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: media.width * 0.9,
                              padding: EdgeInsets.all(media.width * 0.05),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: page,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: media.width * 0.8,
                                      child: Text(
                                        'New version of this app is available in store, please update the app for continue using',
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w600),
                                      )),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Button(
                                      onTap: () async {
                                        if (platform ==
                                            Platform.isAndroid) {
                                          openBrowser(
                                              'https://play.google.com/store/apps/details?id=${package.packageName}');
                                        } else {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          var response = await http.get(Uri.parse(
                                              'http://itunes.apple.com/lookup?bundleId=${package.packageName}'));
                                          if (response.statusCode == 200) {
                                            openBrowser(jsonDecode(
                                                    response.body)['results'][0]
                                                ['trackViewUrl']);
                                          }

                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                      text: 'Update')
                                ],
                              ))
                        ],
                      ),
                    ))
                : Container(),

            //loader
            (_isLoading == true && internet == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),

            //internet is not connected
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        //try again
                        setState(() {
                          internetTrue();
                          getLanguageDone();
                        });
                      },
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
