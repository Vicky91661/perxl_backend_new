import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

var backend = dotenv.env['BACKEND_URL'];

const kPrimaryColor = Colors.deepPurpleAccent;
const kPrimaryLightColor = Color.fromARGB(255, 131, 96, 155);
const Color kWhiteColor = Color(0xffffffff);
const Color kBlackColor = Color(0xff000000);
const Color kGrey0 = Color(0xff555555);
const Color kGrey1 = Color(0xff8D9091);
const Color kGrey2 = Color(0xffCCCCCC);
const Color kGrey3 = Color(0xffEFEFEF);
const Color kRed = Color(0xffC5292A);

const double textTiny = 10.0;
const double textSmall = 12.0;
const double textMedium = 14.0;
const double textExtraLarge = 18.0;
const double textXExtraLarge = 20.0;
const double textBold = 30.0;

const double defaultPadding = 16.0;
 
String baseurl = "$backend/api/v1";
String serverurl = "$backend";
