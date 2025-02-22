import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Viewuserstory extends StatefulWidget {
  const Viewuserstory({key});

  @override
  State<Viewuserstory> createState() => _ViewuserstoryState();
}

class _ViewuserstoryState extends State<Viewuserstory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:


      AppBar(
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: 32,
            child: InkWell(
                onTap: () {

                  Navigator.pop(context);
                },
                child: SvgPicture.asset("assets/mingcute_arrow-up-fill.svg")),
          ),
        ),
        leadingWidth: 40,
        backgroundColor: Colors.white,
        title: Text(
          'My status',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 16,
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w700,
            height: 0,
          ),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 24, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                height: 30,
              ),

              // for (MenuOption m in MenuList)
              //   MenuOptionWidget(
              //       m.imgURl, m.title, m.description, m.onTap ?? () {}),

              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
