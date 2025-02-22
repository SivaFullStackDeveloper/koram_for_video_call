import 'package:flutter/material.dart';

class CommonDatingWidgets{

       errorDialog(BuildContext context) {
    return  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: Text(
            'Sorry There was an Error',
            style: TextStyle(
              color: Color(0xFF303030),
              fontSize: 24,
              fontFamily: 'Helvetica',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
          content: Text(
            'please Try again later',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF707070),
              fontSize: 14,
              fontFamily: 'Helvetica',
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF6701),
                  fontSize: 14,
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

       heightErrorDialog(BuildContext context) {

         return  showDialog(
           context: context,
           builder: (BuildContext context) {
             return AlertDialog(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
               title: Text(
                 'Please Select an height',
                 style: TextStyle(
                   color: Color(0xFF303030),
                   fontSize: 24,
                   fontFamily: 'Helvetica',
                   fontWeight: FontWeight.w700,
                   height: 0,
                 ),
               ),
               content: SizedBox(),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.of(context).pop(); // Close the dialog
                   },
                   child: Text(
                     'Ok',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Color(0xFFFF6701),
                       fontSize: 14,
                       fontFamily: 'Helvetica',
                       fontWeight: FontWeight.w400,
                       height: 0,
                     ),
                   ),
                 ),
               ],
             );
           },
         );
       }

}