// import 'package:flutter/material.dart';
// import 'package:koram_app/Screens/AudioCalling.dart';
//
//
//
//
//
//
//
//
// const audioCallScreen="/audiocallScreen";
//
//
// Route<dynamic> generateRoute(RouteSettings settings) {
//   var data = settings.name;
//   switch (data) {
//     case audioCallScreen:
//       return _getPageRoute(const AudioCallingScreen(callTo: callTo, caller: caller, isReceiving: isReceiving, isfromNotification: isfromNotification), settings);
//
//     default:
//       return _getPageRoute(const LoginScreen(), settings);
//   }
// }
//
// PageRoute _getPageRoute(Widget child, RouteSettings settings) {
//   return _FadeRoute(
//       child: child, routeName: settings.name, enableTransition: true);
// }
//
// class _FadeRoute extends PageRouteBuilder {
//   final Widget child;
//   final String? routeName;
//   bool enableTransition;
//
//   _FadeRoute(
//       {required this.child, this.routeName, this.enableTransition = true})
//       : super(
//     settings: RouteSettings(name: routeName),
//     pageBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         ) =>
//     child,
//     transitionDuration:
//     Duration(milliseconds: enableTransition ? 350 : 0),
//     transitionsBuilder: (
//         BuildContext context,
//         Animation<double> animation,
//         Animation<double> secondaryAnimation,
//         Widget child,
//         ) =>
//         SlideTranstion(animation, child, enableTransition),
//   );
// }
//
// AnimatedWidget bottomToTopTransaction(animation, child) {
//   const begin = Offset(0.0, 1.0);
//   const end = Offset.zero;
//   const curve = Curves.ease;
//
//   var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//
//   return SlideTransition(
//     position: animation.drive(tween),
//     child: child,
//   );
// }
//
// AnimatedWidget SlideTranstion(animation, child, enableTransition) {
//   return SlideTransition(
//     position: Tween(
//         begin: Offset(enableTransition ? 1.0 : 0.0, 0.0),
//         end: Offset(0.0, 0.0))
//         .animate(animation),
//     child: child,
//   );
// }
//
// AnimatedWidget _fade(animation, child) {
//   return SlideTransition(
//     position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
//         .animate(animation),
//     child: child,
//   );
// }