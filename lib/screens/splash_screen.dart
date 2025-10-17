// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
//
// import '../controllers/SplashController.dart';
//
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Get.put(SplashController());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A94FF),
//       body: Stack(
//         children: [
//           ClipPath(
//             clipper: TopShapeClipper(),
//             child: Container(
//               height: size.height * 0.68,
//               width: double.infinity,
//               color: const Color(0xFF0088FF),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             child: ClipPath(
//               clipper: BottomShapeClipper(),
//               child: Container(
//                 height: size.height * 0.415,
//                 width: size.width,
//                 color: const Color(0xFF0088FF),
//               ),
//             ),
//           ),
//           Center(
//             child: SvgPicture.asset(
//               'assets/icons/splashlogo.svg',
//               height: size.height * 0.07,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class TopShapeClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, 0);
//     path.lineTo(0, size.height * 0.86);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height * 1.05,
//       size.width,
//       size.height * 0.6,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }
//
// class BottomShapeClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.moveTo(0, size.height);
//     path.lineTo(0, size.height * 0.15);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height * -0.058,
//       size.width,
//       size.height * 0.52,
//     );
//     path.lineTo(size.width, size.height);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/SplashController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF6366F1),
      body: Center(
        child: SvgPicture.asset(
          'assets/icons/newlogo.svg',
          height: size.height * 0.16,
          width: size.width * 0.5,
        ),
      ),
    );
  }
}
