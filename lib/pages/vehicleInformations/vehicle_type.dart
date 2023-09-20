import 'package:flutter/material.dart';
import 'package:herodriver/functions/functions.dart';
import 'package:herodriver/pages/loadingPage/loading.dart';
import 'package:herodriver/pages/noInternet/nointernet.dart';
import 'package:herodriver/pages/vehicleInformations/vehicle_make.dart';
import 'package:herodriver/pages/vehicleInformations/vehicle_model.dart';
import 'package:herodriver/styles/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herodriver/translation/translation.dart';
import 'package:herodriver/widgets/widgets.dart';

class VehicleType extends StatefulWidget {
  const VehicleType({Key? key}) : super(key: key);

  @override
  State<VehicleType> createState() => _VehicleTypeState();
}

dynamic myVehicalType;
dynamic myVehicleId;
dynamic myVehicleIconFor;
dynamic myVehicleType;

class _VehicleTypeState extends State<VehicleType> {
  bool _loaded = false;
  TextEditingController controller = TextEditingController();

  String dateError = '';

  @override
  void initState() {
    getvehicle();
    super.initState();
  }

//get vehicle type
  getvehicle() async {
    myVehicalType = '';
    myVehicleId = '';
    myVehicleType='';
    myVehicleIconFor = '';
    await getvehicleType();
    if (mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: media.width * 0.08,
                  right: media.width * 0.08,
                  top: media.width * 0.05 + MediaQuery.of(context).padding.top),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  Container(
                      width: media.width * 1,
                      color: topBar,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back)),
                        ],
                      )),
                  SizedBox(
                    height: media.height * 0.04,
                  ),
                  SizedBox(
                      width: media.width * 1,
                      child: Text(
                        languages[choosenLanguage]['text_vehicle_type'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(height: 10),
                  InputField(
                    text: languages[choosenLanguage]
                    ['text_enter_vehicle_type'],
                    textController: controller,
                    onTap: (val) {
                      setState(() {
                        myVehicleType = controller.text;
                      });}
                  ,
                    color: (dateError == '') ? null : Colors.red,
                    inputType: TextInputType.text,
                  ),

                  (myVehicleType != '')
                      ? Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Button(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const VehicleModel()));
                              },
                              text: languages[choosenLanguage]['text_next']),
                        )
                      : Container()
                ],
              ),
            ),

            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      },
                    ))
                : Container(),

            //loader
            (_loaded == false)
                ? const Positioned(top: 0, child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
