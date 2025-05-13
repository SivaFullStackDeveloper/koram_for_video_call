import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Screens/storyPage.dart';
import 'package:provider/provider.dart';

import '../Helper/Helper.dart';
import '../Helper/RuntimeStorage.dart';
import '../Models/NewUserModel.dart';
import '../Models/User.dart';

class MyStatus extends StatefulWidget {
   MyStatus({key});

  @override
  State<MyStatus> createState() => _MyStatusState();
}

class _MyStatusState extends State<MyStatus> {
  int count =0;
  List<Story>?storyList=[];
  @override
  Widget build(BuildContext context) {
    UsersProviderClass UserClass= Provider.of<UsersProviderClass>(context,listen: true);
   log("my status screen built $count");
   log("Userstoary from class ${UserClass.UserStory?.length}");
   count++;
    storyList=UserClass.UserStory;
          if(storyList!.isEmpty)
          {
            Navigator.pop(context);
          }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      elevation: 1,
        title: Text("My Status "),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: RuntimeStorage.instance.PrimaryOrange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      
      body: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: storyList!.length,

        itemBuilder: (context, index) {
          return
            Container(
              width: MediaQuery.of(context).size.width,
              height: 108,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 0, 26),
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(

                      onTap: () {
                        // Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //         builder: (ctx) =>
                        //             StoryViewScreen(loginUser, 0)));

                        UserDetail modifyUserDetails=G.loggedinUser;
                       modifyUserDetails.story=[storyList![index]];

                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) =>
                                    StoryPage(
                                      pos: 0,
                                      Users: [
                                        G.loggedinUser
                                      ],
                                    )));
                      },
                      child: Stack(children: [
                        Container(
                            width: 64,
                            height: 64,
                            child: SvgPicture.asset(
                                "assets/StoryNotseen.svg")),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 7),
                          child: Center(
                            child: ClipOval(
                              child: CachedNetworkImage(
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url,
                                    progress) =>
                                    Center(
                                      child:
                                      CircularProgressIndicator(
                                        value:
                                        progress.progress,
                                      ),
                                    ),
                                imageUrl: 
                                    G.loggedinUser
                                        .publicProfilePicUrl!,

                              ),
                            ),


                          ),
                        )
                      ]),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: (){
                      },
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${storyList![index].seenBy?.length} Views',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 16,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            '${DateFormat('dd MM yyyy').format(DateTime.parse(storyList![index].postedTime??""))}',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 12,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.delete,
                            color: RuntimeStorage.instance.PrimaryOrange),
                        onPressed: ()async {
                          log("Story id ${storyList![index].sId}");
                          int status =await UserClass.deleteStory(G.loggedinUser.phoneNumber!,storyList![index].sId??"");
                          if (status== 200)
                          {

                            CommanWidgets().showSnackBar(context, "Deleted Successfully", Colors.green);
                            // if(storyList!.isEmpty)
                            // {
                            //   log("inside story list empty");
                            //   Navigator.pop(context);
                            // }

                          }else
                          {
                            CommanWidgets().showSnackBar(context, "Error,Unable to Delete", Colors.red);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }
}
