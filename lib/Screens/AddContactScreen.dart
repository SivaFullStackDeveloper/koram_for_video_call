import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Helper/color.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Helper/DBHelper.dart';
import '../Helper/Helper.dart';
import '../Models/NewUserModel.dart';
import '../Models/User.dart';
import 'ChattingScreen.dart';

class AddContactScreen extends StatefulWidget {
  List<UserDetail> friends;
  Function callBackToInit;
  AddContactScreen({key, required this.friends, required this.callBackToInit});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

List<Contact> OnSearchInviteContacts = [];
List<UserDetail> OnSearchKoramContact = [];

List<UserDetail> contactInKoram = [];
List<String> notInKoram = [];
List<Contact> filteredList = [];
bool isContactEmpty = true;
int length = 0;
TextEditingController searchControl = TextEditingController();
bool isLoading = true;
bool isListEnded = false;
List<UserDetail> allUsers = [];
bool isSearching = false;
TextEditingController nameController = TextEditingController();
TextEditingController phoneController = TextEditingController();
List<Contact> allContacts = [];
int batchSize = 25; // Define the size of each batch
List<Contact> displayedContacts = [];

class _AddContactScreenState extends State<AddContactScreen> {
  @override
  void initState() {
    super.initState();

    _fetchContacts();
  }

  String cleanPhoneNumber(String phoneNumber) {
    // Remove dashes and spaces, except the '+' symbol
    return phoneNumber.replaceAll(RegExp(r'[\s-]+'), '');
  }

  void sendAppInvite() {
    String downloadLink =
        'https://play.google.com/apps/internaltest/4701747546792537740';
    String message =
        "Hey, join me on Koram! It's a chat app where you can chat with friends and meet new people nearby. Download it now! \n$downloadLink";

    String url = downloadLink;
    Share.share("$message\n\n$url", subject: "Hey, join me on Koram!");
  }

  void sendDirectSms(
      String message, String downloadLink, List<String> recipients) async {
    List<String> cleanedRecipients = recipients.map((recipient) {
      return recipient.replaceAll(
          RegExp(r'[^\d+]'), ''); // Remove all non-numeric characters
    }).toList();

    String smsMessage = message + ' ' + downloadLink;
    String _recipients = cleanedRecipients.join(';');
    String _url = 'sms:$_recipients?body=${Uri.encodeComponent(smsMessage)}';

    if (await canLaunchUrl(Uri.parse(_url))) {
      await launchUrl(
        Uri.parse(_url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $_url';
    }
  }

  void loadMoreContacts() {
    if (displayedContacts.length < filteredList.length && !isLoading) {
      setState(() {
        isLoading = true;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        int nextBatchSize = displayedContacts.length + batchSize;
        setState(() {
          displayedContacts = filteredList.take(nextBatchSize).toList();
          isLoading = false;
        });
      });
    }
  }

  Future<void> _fetchContacts() async {
    // Check and request contacts permission
    if (await Permission.contacts.request().isGranted) {
      try {
        setState(() {
          isLoading = true;
        });

        final UsersProviderClass usersProvider =
            Provider.of<UsersProviderClass>(context, listen: false);

        // Fetch local mobile contacts
        List<Contact> allContacts =
            await FlutterContacts.getContacts(withProperties: true);

        // Filter contacts to only include those with phone numbers
        allContacts = allContacts
            .where((contact) =>
                contact.phones != null &&
                contact.displayName != null &&
                contact.phones!.isNotEmpty)
            .toList();

        log("Total local contacts fetched: ${allContacts.length}");

        // Extract all phone numbers (normalized)
        List<String> contactList = allContacts
            .expand((contact) =>
                contact.phones!.map((phone) => phone.normalizedNumber ?? ""))
            .toList();

        log("Extracted phone numbers: ${contactList.length}");

        // Send contacts to the API for matching
        ContactResponse contactResponse =
            await usersProvider.getContactUsers(contactList);
        log("API Response: ${contactResponse.toJson()}");

        // Store matched and unmatched contacts
        contactInKoram = contactResponse.matchedUsers;
        notInKoram = contactResponse.unmatchedPhoneNumbers;

        // Filter unmatched contacts from local contacts
        filteredList = allContacts
            .where((contact) => contact.phones!.any((phone) => notInKoram
                .contains(cleanPhoneNumber(phone.normalizedNumber ?? ""))))
            .toList();

        filteredList = filteredList.toSet().toList();

        setState(() {
          displayedContacts = filteredList.take(batchSize).toList();
          isLoading = false;
        });
      } catch (e) {
        log("Error fetching contacts: $e");
        CommanWidgets()
            .showSnackBar(context, "Error, please try again later", Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      log("Contacts permission denied");
      CommanWidgets().showSnackBar(
          context, "Permission denied. Please allow access.", Colors.red);
    }
  }

  // Future<void> _fetchContacts() async {
  //     await Permission.contacts.request();
  //   contactInKoram = [];
  //   final UsersProviderClass usersProvider =
  //       Provider.of<UsersProviderClass>(context, listen: false);
  //   allUsers = usersProvider.finalFriendsList;
  //   contactInKoram = allUsers;
  //   // Request contacts permission
  //   if (await Permission.contacts.request().isDenied) {
  //     await Permission.contacts.request();
  //   } else {
  //     try{
  //       // Fetch contacts with only phone numbers
  //       allContacts = await FlutterContacts.getContacts(
  //           withThumbnail: false, );

  //       // Extract phone numbers
  //       allContacts = allContacts.where((con) => con.phones != null && con.displayName!=null&& con.phones!.isNotEmpty).toList();
  //       log("all contact length ${allContacts.length}");

  //       // Extract phone numbers
  //       List<String> contactList = allContacts
  //           .expand(
  //               (contact) => contact.phones!.map((phone) => phone.normalizedNumber ?? ""))
  //           .toList();

  //       // Send contacts to your API in batches if necessary
  //       ContactResponse contactResponse =
  //       await usersProvider.getContactUsers(contactList);
  //       log("the response of getcontact on add contact screen ${contactResponse.toJson()}");

  //       contactInKoram=contactResponse.matchedUsers;
  //       notInKoram = contactResponse.unmatchedPhoneNumbers;
  //       //
  //       // Filter unmatched contacts
  //       filteredList = allContacts
  //           .where((contact) => contact.phones!.any((phone) =>
  //           notInKoram.contains(cleanPhoneNumber(phone.normalizedNumber ?? ""))))
  //           .toList();
  //       filteredList = filteredList.toSet().toList();

  //       setState(() {
  //         displayedContacts = filteredList.take(batchSize).toList();
  //       });
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }catch(e)
  //     {
  //       log("error while fetching $e");
  //       CommanWidgets().showSnackBar(context, "Error,Please try again later",Colors.red);
  //       setState(() {
  //         isLoading = false;
  //       });
  //       return;
  //     }

  //   }
  // }

  void filterContacts(String query) {
    if (isLoading) {
      CommanWidgets().showSnackBar(
          context, "Please wait until the contacts are loaded", Colors.red);
      return;
    }
    setState(() {
      // Filter the contacts based on the query
      OnSearchInviteContacts = filteredList.where((contact) {
        return contact.displayName!.toLowerCase().contains(query.toLowerCase());
      }).toList();
      OnSearchKoramContact = contactInKoram.where((contact) {
        return contact.privateName!.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Reset displayedContacts to start with a subset of the filtered results
      displayedContacts = OnSearchInviteContacts.take(batchSize).toList();
    });
  }

  void loadMoreFilteredContacts() {
    if (displayedContacts.length < OnSearchInviteContacts.length &&
        !isLoading) {
      setState(() {
        isLoading = true;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        int nextBatchSize = displayedContacts.length + batchSize;
        setState(() {
          displayedContacts =
              OnSearchInviteContacts.take(nextBatchSize).toList();
          isLoading = false;
        });
      });
    }
  }

  Widget inviteRowWidget(Contact c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: (c.photo != null && c.photo!.isNotEmpty)
                ? CircleAvatar(
                    backgroundImage: AssetImage("assets/profile.png"),
                    foregroundImage: MemoryImage(c.photo!),
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                  )
                : CircleAvatar(
                    backgroundImage: AssetImage("assets/profile.png"),
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                  ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Text(
              c.displayName ?? "Unknown",
              style: TextStyle(
                color: Color(0xFF303030),
                fontSize: 16,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                String message =
                    "Hey, join me on Koram! It’s a chat app where you can chat with friends and meet new people nearby. Download it now!";
                String downloadLink =
                    'https://play.google.com/apps/internaltest/4701747546792537740';

                if (c.phones != null && c.phones!.isNotEmpty) {
                  List<String> recipients = [
                    c.phones!.first.normalizedNumber!.trim()
                  ];
                  sendDirectSms(message, downloadLink, recipients);
                } else {
                  log("No phone number found for ${c.displayName}");
                }
              },
              child: Text(
                "Invite",
                style: TextStyle(color: backendColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget inviteRowWidget(Contact c) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 48,
  //           height: 48,
  //           clipBehavior: Clip.antiAlias,

  //           decoration: ShapeDecoration(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(100),
  //             ),
  //           ),
  //           child: c.photo!.isNotEmpty
  //               ? CircleAvatar(
  //                   backgroundImage: AssetImage("assets/profile.png"),
  //                   foregroundImage: MemoryImage(c.photo!),
  //                   // onForegroundImageError: (){}AssetImage("assets/profile.png"),
  //                   radius: 60,
  //                   backgroundColor: Colors.grey[300],
  //                 )
  //               : CircleAvatar(
  //                   backgroundImage: AssetImage("assets/profile.png"),
  //                   radius: 60,
  //                   backgroundColor: Colors.grey[300],
  //                 ),
  //           // ? Image.memory(c.avatar!, fit: BoxFit.cover,)
  //           // : Image.asset("assets/profile.png"),
  //         ),
  //         SizedBox(
  //           width: 12,
  //         ),
  //         SizedBox(
  //           width: MediaQuery.of(context).size.width / 2,
  //           child: Text(
  //             c.displayName.toString(),
  //             style: TextStyle(
  //                 color: Color(0xFF303030),
  //                 fontSize: 16,
  //                 fontFamily: 'Helvetica',
  //                 fontWeight: FontWeight.w700,
  //                 overflow: TextOverflow.ellipsis),
  //             maxLines: null,
  //           ),
  //         ),
  //         Expanded(child: SizedBox()),
  //         Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: TextButton(
  //               onPressed: () {
  //                 // try{
  //                 String message =
  //                     "Hey, join me on Koram! It\'s a chat app where you can chat with friends and meet new people nearby. Download it now!";
  //                 String downloadLink =
  //                     'https://play.google.com/apps/internaltest/4701747546792537740';
  //                 log("pjones ${c.phones?[0].normalizedNumber}");
  //                 List<String> recipients = [c.phones?[0].normalizedNumber!.trim() ?? ""];

  //                 sendDirectSms(message, downloadLink, recipients);

  //               },
  //               child: Text("Invite")),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Future<void> addContact() async {
  //   // Request permissions to access contacts
  //   if (await Permission.contacts.request().isGranted) {
  //     // Create a new contact
  //     Contact newContact = Contact(
  //       displayName: nameController.text,
  //       phones: [
  //         Phone(
  //           phoneController.text,
  //           label: PhoneLabel.mobile, // Corrected syntax for PhoneLabel
  //         ),
  //       ],
  //     );

  //     // Add the contact to the device
  //     await FlutterContacts.insertContact(newContact);

  //     // Clear the text fields
  //     nameController.clear();
  //     phoneController.clear();

  //     // Show a success message
  //     CommanWidgets()
  //         .showSnackBar(context, "Contact added successfully", Colors.green);
  //     Navigator.pop(context);
  //   } else {
  //     // If permissions are not granted, show an error message
  //     CommanWidgets().showSnackBar(context, "Error adding contact", Colors.red);
  //   }
  // }

  Future<void> addContact() async {
    // Request permission to access contacts
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      try {
        // Create a new contact using the provided name and phone
        Contact newContact = Contact(
          displayName: nameController.text,
          name: Name(
            first: nameController.text,
          ),
          phones: [
            Phone(
              phoneController.text,
              label: PhoneLabel.mobile, // Correct syntax for PhoneLabel
            ),
          ],
        );

        // Insert the new contact to the device
        await FlutterContacts.insertContact(newContact);

        // Clear the text fields
        nameController.clear();
        phoneController.clear();

        // Show a success message
        CommanWidgets()
            .showSnackBar(context, "Contact added successfully", Colors.green);

        // Fetch the updated contacts list after adding a new contact
        await _fetchContacts(); // Assuming this is the method to fetch contacts

        // Close the current screen
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors that occur during the contact insertion
        log("Error adding contact: $e");
        CommanWidgets().showSnackBar(
            context, "Error adding contact, please try again", Colors.red);
      }
    } else {
      // If permissions are denied, show error message
      CommanWidgets().showSnackBar(context,
          "Permission denied. Please enable contacts permission", Colors.red);
    }
  }

  Widget koramRowWidget(UserDetail c) {
    UserDetail? loggedUser =
        Provider.of<UsersProviderClass>(context, listen: false).LoggedUser;

    return InkWell(
      onTap: () async {
        bool addFriendApproved = false;
        if (loggedUser != null) {
          if (!loggedUser.friendList!.contains(c.phoneNumber)) {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              builder: (ctx) => Container(
                padding: EdgeInsets.all(16.0),
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    Text("${c.publicName} add as friend",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () async {
                              int res = await UsersProviderClass()
                                  .addFriendByPhoneNumber(c.phoneNumber!);
                              if (res == 200) {
                                log("added friend ${c.phoneNumber}");
                                CommanWidgets().showSnackBar(
                                    context, "Added as friend", Colors.green);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ChattingScreen(
                                    otherUserNumber: c.phoneNumber!,
                                    callBack: () {
                                      widget.callBackToInit();
                                    },
                                    otherUserDetail: c,
                                  ),
                                ));
                              }
                            },
                            child: Container(
                                height: 50,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: backendColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                              height: 50,
                              width: 100,
                              decoration: BoxDecoration(
                                color: backendColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 50)
                  ],
                ),
              ),
            );

            log("clicked number ${c.phoneNumber}");
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: c.privateProfilePicUrl != ""
                  ? CircleAvatar(
                      backgroundImage: AssetImage("assets/profile.png"),
                      foregroundImage: CachedNetworkImageProvider(c
                                  .publicProfilePicUrl !=
                              null
                          ?  c.publicProfilePicUrl!
                          : "https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg"),
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                    )
                  : CircleAvatar(
                      backgroundImage: AssetImage("assets/profile.png"),
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                    ),
            ),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.privateName != null && c.privateName!.isNotEmpty
                      ? c.privateName!
                      : "Unknown User",
                  style: TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 16,
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                Text(
                  c.phoneNumber == G.userPhoneNumber ? "You" : c.phoneNumber!,
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 14,
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            height: 32,
            child: InkWell(
                onTap: () {
                  if (isSearching == true) {
                    setState(() {
                      isSearching = false;
                      searchControl.clear();
                    });
                    return;
                  }
                  widget.callBackToInit();
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  "assets/mingcute_arrow-up-fill.svg",
                )),
          ),
        ),
        leadingWidth: 40,
        backgroundColor: Colors.white,
        title: isSearching
            ? TextField(
                controller: searchControl,
                decoration: InputDecoration(),
                onChanged: (e) {
                  filterContacts(e);
                },
                onSubmitted: (k) {},
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                child: Text(
                  'Search Contact',
                  style: TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 16,
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
              ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                isSearching = !isSearching;
                searchControl.clear();
              });
            },
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(),
              child: Container(child: SvgPicture.asset("assets/Vector.svg")),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              sendAppInvite();
            },
            child: SvgPicture.asset(
              "assets/ShareNetwork.svg",
              color: RuntimeStorage().PrimaryOrange,
            ),
          ),
          // SvgPicture.asset("assets/more-vertical.svg"),
          SizedBox(width: 15.11),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            log("scrool eneded");
            // Check if we have reached the end of the scrollable content
            if (scrollInfo.metrics.extentAfter == 0) {
              if (!isLoading ||
                  isSearching &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                log("reached max scroll extent ");
                isSearching ? loadMoreFilteredContacts() : loadMoreContacts();
                return true;
              }
              return false;
            }
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 24, 0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height / 3,
                              maxWidth: MediaQuery.of(context).size.width / 3),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration:
                                        InputDecoration(labelText: 'Name'),
                                  ),
                                  TextField(
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                        labelText: 'Phone Number'),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: addContact,
                                    child: Text('Add Contact'),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: backendColor,
                              borderRadius: BorderRadius.circular(100)),
                          child: Icon(
                            Icons.person_add,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          'New Contact',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                  child: Text(
                    'Contacts in Koram',
                    style: TextStyle(
                      color: Color(0xFF667084),
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                isSearching
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: OnSearchKoramContact.length,
                        itemBuilder: (context, index) {
                          return koramRowWidget(OnSearchKoramContact[index]);
                        },
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: contactInKoram.length,
                        itemBuilder: (context, index) {
                          return koramRowWidget(contactInKoram[index]);
                          // return koramRowWidget(G.loggedinUser);
                        },
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
                  child: Text(
                    'Invite to Koram',
                    style: TextStyle(
                      color: Color(0xFF667084),
                      fontSize: 12,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                isSearching
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: OnSearchInviteContacts.length,
                        itemBuilder: (ctx, index) {
                          return inviteRowWidget(OnSearchInviteContacts[index]);
                        })
                    : ListView.builder(
                        shrinkWrap: true,

                        physics: NeverScrollableScrollPhysics(),

                        // itemCount: allContacts.length,
                        itemBuilder: (ctx, index) {
                          if (index == displayedContacts.length) {
                            log("length ${displayedContacts.length} contact length ${allContacts.length}");
                            return Center(
                              child: CircularProgressIndicator(
                                color: backendColor,
                              ),
                            );
                          } else {
                            return inviteRowWidget(displayedContacts[index]);
                          }
                        },
                        itemCount:
                            displayedContacts.length + (isLoading ? 1 : 0),
                        // itemBuilder: (ctx, index) {
                        //   return inviteRowWidget(allContacts[index]);
                        // }
                      ),
                GestureDetector(
                  onTap: () {
                    sendAppInvite();
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: IconButton(
                            onPressed: () {
                              sendAppInvite();
                            },
                            icon: Icon(
                              Icons.share,
                              color: RuntimeStorage().PrimaryOrange,
                            )),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        'Share invite link',
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 16,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      )
                      //
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
