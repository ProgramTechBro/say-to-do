// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import '../controllers/PremiumController.dart';
// import '../services/AdService.dart';
// import '../utils/ClearSubscriptionTitle.dart';
// import '../utils/UrlLauncher.dart';
// import '../utils/constants.dart';
//
//
// class PremiumView extends StatefulWidget {
//   final bool showSkip;
//
//   const PremiumView({Key? key, this.showSkip = false}) : super(key: key);
//
//   @override
//   State<PremiumView> createState() => _PremiumViewState();
// }
//
// class _PremiumViewState extends State<PremiumView> {
//   final PremiumController controller = Get.put(PremiumController());
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: screenHeight * 0.04),
//             Align(
//               alignment: Alignment.topRight,
//               child: widget.showSkip?
//               TextButton(
//                 onPressed: () async {
//                   if (controller.isProUser.value) {
//                     Get.offAllNamed('/main');
//                   } else {
//                     bool res = await Get.find<AdService>().showInterstitialAd(
//                       onAdDismissedFullScreenContent: (p0) async {
//                         Get.offAllNamed('/main');
//                       },
//                       onAdFailedToShowFullScreenContent: (p0, p1) {
//                         Get.offAllNamed('/main');
//                       },
//                     );
//                     if (!res) {
//                       Get.offAllNamed('/main');
//                     }
//                   }
//                 },
//                 child: Obx(() => Text(
//                   controller.isProUser.value ? "Next" : "Skip",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: screenWidth * 0.04,
//                   ),
//                 )),
//               )
//                   : IconButton(
//                 icon: const Opacity(
//                   opacity: 0.7,
//                   child: Icon(Icons.close, color: Colors.white),
//                 ),
//                 onPressed: () {
//                   Get.back();
//                 },
//               ),
//             ),
//             SvgPicture.asset(
//               'assets/images/exit_logo.svg',
//               width: screenWidth * 0.7,
//               height: screenHeight * 0.16,
//               fit: BoxFit.contain,
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Obx(() {
//               if (controller.isProUser.value) {
//                 return const SizedBox.shrink();
//               }
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'GO PREMIUM',
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.005),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: screenWidth*0.03),
//                       child: Text(
//                         '• Solve Geometry, Algebra and Calculus\n'
//                             '• Quick Answer, Brief Essay, Math Solver \n'
//                             '• Saved Unlimited Conversation\n'
//                             '• Remove Ads',
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.04,
//                           color: Colors.white,
//                           height: 1.5,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                 ],
//               );
//             }),
//             // Align(
//             //   alignment: Alignment.centerLeft,
//             //   child: Text(
//             //     'GO PREMIUM',
//             //     style: TextStyle(
//             //       fontSize: screenWidth * 0.05,
//             //       fontWeight: FontWeight.bold,
//             //       color: Colors.white,
//             //     ),
//             //   ),
//             // ),
//             // SizedBox(height: screenHeight * 0.01),
//             // Align(
//             //   alignment: Alignment.centerLeft,
//             //   child: Text(
//             //     '• Unlock All Premium Conversation\n'
//             //     '• Practice, Challenges, Grammar & Record\n'
//             //     '• Saved Unlimited Conversation\n'
//             //     '• Remove Ads',
//             //     style: TextStyle(
//             //       fontSize: screenWidth * 0.04,
//             //       color: Colors.white,
//             //       height: 1.5,
//             //     ),
//             //   ),
//             // ),
//             // SizedBox(height: screenHeight * 0.02),
//             Obx(() {
//               if (controller.isProUser.value) {
//                 return Text(
//                   "You have already subscribed. Please Manage Subscriptions in play store",
//                   style: GoogleFonts.roboto(color: Colors.white),
//                 );
//               }
//               return Column(
//                 children: List.generate(
//                     controller.products.isNotEmpty
//                         ? controller.products.length
//                         : 0, (index) {
//                   return buildPlanContainer(
//                     product: controller.products[index],
//                     title: cleanSubscriptionTitle(
//                         controller.products[index].title),
//                     price: controller.products[index].description,
//                     extraText: "",
//                     pricePerWeek: controller
//                         .getSubscriptionPrice(controller.products[index]),
//                     period: '',
//                     index: index,
//                     bestOffer:
//                     (controller.products[index].productDetails.productId ==
//                         'deep_yearly'),
//                   );
//                 }),
//               );
//             }),
//             // SizedBox(height: screenHeight * 0.01),
//             Obx(() {
//               return SizedBox(
//                 height: controller.isProUser.value
//                     ? screenHeight * 0.02
//                     : screenHeight * 0.01,
//               );
//             }),
//             Text(
//               'Cancel Anytime',
//               style: TextStyle(
//                 fontSize: screenWidth * 0.035,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.015),
//             Container(
//               //padding: EdgeInsets.zero,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding:
//                   EdgeInsets.symmetric(vertical: screenHeight * 0.0195),
//                 ),
//                 onPressed: () {
//                   if (PremiumController.to.isValidSubscription()) {
//                     Get.back();
//                   } else {
//                     if (controller.products.isNotEmpty) {
//                       controller.purchaseSubscription();
//                     } else {
//                       BotToast.showText(
//                         text: "No subscription Selected",
//                         duration: const Duration(seconds: 2),
//                       );
//                     }
//                   }
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       (controller.products.isNotEmpty) &&
//                           ((controller
//                               .products[
//                           controller.selectedPlan.value]
//                               .productDetails
//                               .subscriptionOfferDetails
//                               ?.length ??
//                               0)) >
//                               1
//                           ? 'Continue For Free'
//                           : "Continue",
//                       style: GoogleFonts.roboto(
//                         fontSize: screenWidth * 0.042,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // urlLauncher(AppConstants.termsOfServiceLink);
//                   },
//                   child: Text(
//                     'Terms of Use',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: screenWidth * 0.03,
//                         decoration: TextDecoration.underline,
//                         decorationColor: Colors.white),
//                   ),
//                 ),
//                 Text(
//                   '|',
//                   style: TextStyle(
//                       color: Colors.white, fontSize: screenWidth * 0.03),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     urlLauncher(AppConstants.privacyPolicyLink);
//                   },
//                   child: Text(
//                     'Privacy Policy',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: screenWidth * 0.03,
//                         decoration: TextDecoration.underline,
//                         decorationColor: Colors.white),
//                   ),
//                 ),
//                 Text(
//                   '|',
//                   style: TextStyle(
//                       color: Colors.white, fontSize: screenWidth * 0.03),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Restore',
//                     style: TextStyle(
//                         color: Colors.white, fontSize: screenWidth * 0.03),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.02),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildPlanContainer(
//       {required String title,
//         required String price,
//         required String extraText,
//         required String pricePerWeek,
//         required int index,
//         required String period,
//         bool bestOffer = false,
//         GooglePlayProductDetails? product}) {
//     return GestureDetector(
//       onTap: () => controller.selectPlan(index), // <-- Updates selected plan
//       child: Obx(() {
//         bool isSelected = controller.selectedPlan.value == index;
//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: const EdgeInsets.symmetric(vertical: 6),
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color.fromRGBO(229, 126, 1, 1)
//                     : const Color.fromRGBO(255, 255, 255, 0.2),
//                 borderRadius: BorderRadius.circular(12),
//                 border: isSelected
//                     ? Border.all(color: Colors.white, width: 2)
//                     : null,
//               ),
//               alignment: Alignment.center,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           title,
//                           style: GoogleFonts.roboto(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color:  Colors.white,),
//                         ),
//                       ),
//                       Text(
//                         pricePerWeek,
//                         style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 3,
//                   ),
//                   if (price.isNotEmpty)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             price,
//                             style: GoogleFonts.roboto(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                                 color: Colors.white),
//                           ),
//                         ),
//                         Text(
//                           period,
//                           style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     )
//                   else
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         period,
//                         style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   const SizedBox(
//                     height: 3,
//                   ),
//                   if (extraText.isNotEmpty)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Text(
//                           extraText,
//                           style: GoogleFonts.roboto(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: Colors.white),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//             if (bestOffer)
//               Positioned(
//                 top: -6,
//                 right: 25,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     controller.getTrialText(product!),
//                     style:TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
