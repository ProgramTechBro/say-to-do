// import 'package:first_project/controllers/MainNavBarController.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
//
// import '../utils/constants.dart';
//
// class VoiceRecordingOverlay extends StatelessWidget {
//   final MainNavBarController controller;
//
//   const VoiceRecordingOverlay({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: Container(
//         color: Colors.black.withOpacity(0.7),
//         child: Center(
//           child: Material(
//             color: Colors.transparent,
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: Container(
//                 width: 280,
//                 height: 320,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Recording...',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Lottie.asset(
//                       'assets/Lottie/recording.json',
//                       width: 120,
//                       height: 120,
//                       repeat: true,
//                     ),
//                     const SizedBox(height: 24),
//                     SizedBox(
//                       width: 100,
//                       height: 40,
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           await controller.stopVoiceRecordingAndAnalyze();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF8F8FA),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           padding: EdgeInsets.zero,
//                         ),
//                         child: const Text(
//                           'Stop',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

import '../controllers/MainNavBarController.dart';

class VoiceRecordingBottomSheet extends StatelessWidget {
  final MainNavBarController controller;

  const VoiceRecordingBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: bottomPadding + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listening',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  await controller.cancelVoiceRecording();
                },
                child: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 30,
            child: AnimatedWaveList(
              stream: Stream.periodic(
                const Duration(milliseconds: 70),
                    (count) => Amplitude(
                  current: Random().nextDouble() * 100,
                  max: 100,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await controller.cancelVoiceRecording();
                },
                icon: const Icon(Icons.delete_outline,color: Colors.red,),
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  await controller.stopVoiceRecordingAndAnalyze();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC3E2FF),
                  ),
                  child: Container(
                    width: 35,
                    height: 35,
                    padding: EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6663F1),
                    ),
                    child: SvgPicture.asset('assets/icons/send.svg'),
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
