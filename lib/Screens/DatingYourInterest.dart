import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Screens/DatingDoYouDrink.dart';
import 'package:http/http.dart' as http;

import '../Helper/CommonDatingWidgets.dart';
import '../Helper/Helper.dart';

class DatingYourInterest extends StatefulWidget {
  const DatingYourInterest({key});

  @override
  State<DatingYourInterest> createState() => _DatingYourInterestState();
}

class _DatingYourInterestState extends State<DatingYourInterest> {
  List<String> InterestOptions = [
    'Sports',
    'Dance',
    'Music',
    'Reading',
    'Cooking',
    'Traveling',
    'Movies',
    'Gaming',
    'Fitness',
    'Art',
    'Photography',
    'Fashion',
    'Technology',
    'Nature',
    'Animals',
    'Writing',
    'Hiking',
    'Foodie',
    'Yoga',
    'Science',
    'Crafting',
    'Theater',
    'Volunteering',
    'Camping',
    'History',
    'Astrology',
    'Cars',
    'DIY',
    'Socializing',
  ];
  List<String> SelectedInterestByUser = [];
  @override
  void initState() {
    SelectedInterestByUser = ["Sports"];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: width,
          height: height,
          child: Container(
            height: height,
            width: width,
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: SvgPicture.asset("assets/CaretLeft.svg"),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                        ),
                        Text(
                          'Koram',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 23.96,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: SizedBox(
                            width: 258,
                            child: Text(
                              'Your interests',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 24,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Pick up to 5 things you love. It’ll help you match with people who love them too.',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    height: 34,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height/1.6,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(

                          children: [
                            Wrap(
                                spacing: 12.0,
                                runSpacing: 12.0,

                                children: [
                                  for (String i in InterestOptions)
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          if(SelectedInterestByUser.contains(i))
                                          {
                                            SelectedInterestByUser.remove(i);

                                          }else
                                          {
                                            SelectedInterestByUser.add(i);

                                          }
                                        });

                                      },
                                      child: Chip(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(width: 1, color:  SelectedInterestByUser.contains(i)
                                              ?Color(0xFFFF6701):Color(0xFFF2F2F2)),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        label: Text(i),
                                        backgroundColor:
                                            SelectedInterestByUser.contains(i)
                                                ? Color(0xFFFF6701)
                                                : Colors.white,
                                        labelStyle: TextStyle(
                                          color: SelectedInterestByUser.contains(i)
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: GestureDetector(
              onTap: () async{
                String uploadUrl = G.HOST + "api/v1/insertDatingDetails";
                var response =
                    await http.post(Uri.parse(uploadUrl),body: {"phone_number": G.userPhoneNumber,"insertType":"interest","interest":SelectedInterestByUser.join(",")});
                if (response.statusCode == 200) {

                  log("inside success of edit ");

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return DatingDoYouDrink();
                  }));
                } else {
                  await CommonDatingWidgets().errorDialog(context);
                }



              },
              child: Container(
                width: 350,
                height: 54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                decoration: ShapeDecoration(
                  color: Color(0xFFFF6701),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              )

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       child: Padding(
              //         padding: const EdgeInsets.only(bottom: 20.0),
              //         child: Container(
              //           height: 54,
              //           padding: const EdgeInsets.symmetric(
              //               horizontal: 10, vertical: 18),
              //           decoration: ShapeDecoration(
              //             color: Color(0xFFFF6701),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //           ),
              //           child: Text(
              //             'Next',
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //               fontFamily: 'Helvetica',
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              ),
        ),
      ),
    );
  }
}
