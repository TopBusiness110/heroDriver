import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herodriver/functions/functions.dart';
import 'package:herodriver/pages/loadingPage/loading.dart';
import 'package:herodriver/pages/noInternet/nointernet.dart';
import 'package:herodriver/pages/vehicleInformations/vehicle_year.dart';
import 'package:herodriver/styles/styles.dart';
import 'package:herodriver/translation/translation.dart';
import 'package:herodriver/widgets/widgets.dart';

class VehicleModel extends StatefulWidget {
  const VehicleModel({Key? key}) : super(key: key);

  @override
  State<VehicleModel> createState() => _VehicleModelState();
}

dynamic vehicleModelId;
dynamic vehicleModelName;
dynamic myVehicleModel;

class _VehicleModelState extends State<VehicleModel> {
  bool _loaded = false;
  TextEditingController controller = TextEditingController();

  String dateError = '';
  @override
  void initState() {
    getVehicleMod();

    super.initState();
  }

//get vehicle model
  getVehicleMod() async {
    vehicleModelId = '';
    vehicleModelName = '';
    myVehicleModel='';
    await getVehicleModel();
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
              color: page,
              height: media.height * 1,
              width: media.width * 1,
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
                        languages[choosenLanguage]['text_vehicle_model'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  InputField(
                    text: languages[choosenLanguage]
                    ['text_enter_vehicle_model'],
                    textController: controller,
                    onTap: (val) {
                      setState(() {
                        myVehicleModel = controller.text;
                      });}
                    ,
                    color: (dateError == '') ? null : Colors.red,
                    inputType: TextInputType.text,
                  ),

                  (myVehicleModel != '')
                      ? Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Button(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const VehicleYear()));
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
