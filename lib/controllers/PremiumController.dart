// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:http/http.dart' as http;
// import '../services/AdCheckService.dart';
// class PremiumController extends GetxController {
//   static PremiumController get to => Get.find();
//   var selectedPlan = 0.obs;
//   var isRestoringManually = false;
//   var isLoading = false;
//   final adCheckService = Get.find<AdCheckService>();
//
//   void selectPlan(int index) {
//     selectedPlan.value = index;
//   }
//
//   final InAppPurchase _iap = InAppPurchase.instance;
//   StreamSubscription<List<PurchaseDetails>>? _subscription;
//   final RxList<GooglePlayProductDetails> products =
//       <GooglePlayProductDetails>[].obs;
//   final RxBool isProUser = false.obs;
//   final Rx<DateTime?> expiryDate = Rx<DateTime?>(null);
//
//   @override
//   void onInit() {
//     super.onInit();
//     // initSubscription();
//     fetchProducts();
//   }
//
//   Future<void> initSubscription() async {
//     final bool available = await _iap.isAvailable();
//     if (!available) return;
//     _subscription = _iap.purchaseStream.listen((purchaseDetailsList) {
//       _handlePurchaseUpdates(purchaseDetailsList);
//     });
//   }
//
//   bool isValidSubscription() {
//     return isProUser.value &&
//         expiryDate.value != null &&
//         expiryDate.value!.isAfter(DateTime.now());
//   }
//
//   Future<void> fetchProducts() async {
//     const Set<String> _kIds = {'deep_weekly', 'deep_monthly', 'deep_yearly'};
//     final ProductDetailsResponse response =
//     await _iap.queryProductDetails(_kIds);
//     // var list = response.productDetails
//     //     .map((product) => product as GooglePlayProductDetails)
//     //     .toList();
//     //
//     // list.sort((a, b) {
//     //   const order = {
//     //     'seek_yearly': 0,
//     //     'seek_monthly': 1,
//     //     'seek_weekly': 2,
//     //   };
//     //   return (order[a.productID] ?? 99).compareTo(order[b.productID] ?? 99);
//     // });
//     var list = response.productDetails
//         .map((product) => product as GooglePlayProductDetails)
//         .toList();
//
//     // Sort list in desired order: yearly > monthly > weekly
//     list.sort((a, b) {
//       const order = {
//         'deep_yearly': 0,
//         'deep_monthly': 1,
//         'deep_weekly': 2,
//       };
//       return (order[a.id] ?? 99).compareTo(order[b.id] ?? 99);
//     });
//     // if (list.length > 2) {
//     //   list.removeWhere((element) {
//     //     return element.id == 'monthly_pro' && element.rawPrice > 0;
//     //   });
//     // }
//     products.assignAll(list);
//   }
//
//   String getSubscriptionPrice(GooglePlayProductDetails product) {
//     if (product.productDetails.subscriptionOfferDetails == null ||
//         product.productDetails.subscriptionOfferDetails!.isEmpty) {
//       return product
//           .productDetails.oneTimePurchaseOfferDetails?.formattedPrice ??
//           "N/A";
//     }
//
//     // Get the best available offer (normally index 0)
//     var offer = product.productDetails.subscriptionOfferDetails!.first;
//
//     String freeTrialText = "";
//     String actualPrice = "";
//
//     for (var phase in offer.pricingPhases) {
//       if (phase.priceAmountMicros == 0) {
//         // This is a free trial phase
//         freeTrialText = "";
//       } else {
//         // This is the actual subscription price
//         actualPrice = phase.formattedPrice;
//       }
//     }
//
//     //return "$freeTrialText$actualPrice/${product.productDetails.productId == 'monthly_pro' ? '30' : '7'} Days";
//     return "$freeTrialText$actualPrice/${_getPeriodLabel(product.productDetails.productId)}";
//   }
//
//   String _getPeriodLabel(String productId) {
//     switch (productId) {
//       case 'deep_weekly':
//         return '7 Days';
//       case 'deep_monthly':
//         return '30 Days';
//       case 'deep_yearly':
//         return '12 Months';
//       default:
//         return 'Period';
//     }
//   }
//
//   String getTrialText(GooglePlayProductDetails product) {
//     if (product.productDetails.subscriptionOfferDetails == null ||
//         product.productDetails.subscriptionOfferDetails!.isEmpty) {
//       return 'Best Offer';
//     }
//
//     // Get the best available offer (normally index 0)
//     var offer = product.productDetails.subscriptionOfferDetails!.first;
//
//
//     for (var phase in offer.pricingPhases) {
//       if (phase.priceAmountMicros == 0) {
//         // This is a free trial phase
//         return '3 Days Free';
//       } else {
//         // This is the actual subscription price
//         return "Best Offer";
//       }
//     }
//     return 'Best Offer';
//
//   }
//
//   Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
//     BotToast.showLoading();
//     for (var purchase in purchases) {
//       if (purchase.status == PurchaseStatus.purchased ||
//           purchase.status == PurchaseStatus.restored) {
//         //ToastService.showToast('Verifying your purchase...');
//         await _verifyPurchaseWithServer(purchase as GooglePlayPurchaseDetails);
//         _iap.completePurchase(purchase);
//       } else if (purchase.status == PurchaseStatus.error) {
//         debugPrint("Purchase Error: ${purchase.error}");
//         BotToast.showText(text: 'Unable to Complete Purchase');
//       } else if (purchase.status == PurchaseStatus.pending) {
//         BotToast.showText(text: 'Purchase Pending');
//         await _verifyPurchaseWithServer(purchase as GooglePlayPurchaseDetails);
//         _iap.completePurchase(purchase);
//       } else if (purchase.status == PurchaseStatus.canceled) {
//         //Canceled
//       }
//     }
//     if (purchases.isEmpty) {
//       if (isRestoringManually) {
//         isRestoringManually = false;
//         BotToast.showText(text: "No Purchase Found");
//         BotToast.closeAllLoading();
//         return;
//       }
//     }
//     BotToast.closeAllLoading();
//   }
//
//   Future<void> _verifyPurchaseWithServer(
//       GooglePlayPurchaseDetails purchase) async {
//     log(purchase.verificationData.serverVerificationData);
//     try {
//       final url = Uri.parse(
//           'https://apicomboseekmodel.comboseek.com/api/google/play-services/verify-subscription');
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           // 'packageName': 'com.your.app',
//           'subscriptionId': purchase.productID,
//           'purchaseToken': purchase.verificationData.serverVerificationData,
//           'package_name': 'com.aimathsolver'
//         }),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body)['data'];
//         if (data['expiryTimeMillis'] != null) {
//           DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(
//               int.parse(data['expiryTimeMillis']));
//           bool isProUser = DateTime.now().isBefore(expiryDate);
//           bool isPaymentValid = data['paymentState'] == 1;
//           if (isProUser && isPaymentValid) {
//             await _saveSubscriptionStatus(true, expiryDate);
//             if (isRestoringManually) {
//               isRestoringManually = false;
//               BotToast.showText(text: "Subscription restored successfully");
//             }
//           } else {
//             // await _saveSubscriptionStatus(false, null);
//             BotToast.showText(text: "Invalid or expired subscription");
//           }
//         } else {
//           BotToast.showText(text: "Subscription expiry data missing");
//         }
//       } else {
//         debugPrint("-----------SERVER RESPONSE: ${response.statusCode} - ${response.body}----------------");
//         BotToast.showText(text: "Server Error");
//       }
//     } catch (e) {
//       debugPrint("Error verifying purchase: $e");
//       BotToast.showText(text: "Error verifying purchase");
//     }
//     return;
//   }
//
//   Future<void> _saveSubscriptionStatus(bool isPro, DateTime? expiry) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? expiryString = prefs.getString("expiryDate");
//     var expiryDt = expiry;
//     if (expiryString != null) {
//       DateTime expiryOld = DateTime.parse(expiryString);
//       if (expiryOld.isAfter(expiry!)) {
//         expiryDt = expiryOld;
//       } else {
//         expiryDt = expiry;
//       }
//     }
//     await prefs.setBool("isProUser", isPro);
//     await prefs.setString("expiryDate", expiryDt!.toIso8601String());
//     isProUser.value = isPro;
//     expiryDate.value = expiryDt;
//     await adCheckService.refreshAdStatus();
//   }
//
//   Future<void> checkSubscriptionStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool isPro = prefs.getBool("isProUser") ?? false;
//     String? expiryString = prefs.getString("expiryDate");
//     if (isPro && expiryString != null) {
//       DateTime expiry = DateTime.parse(expiryString);
//       if (DateTime.now().isAfter(expiry)) {
//         await _saveSubscriptionStatus(false, expiry);
//       } else {
//         isProUser.value = true;
//         expiryDate.value = expiry;
//         await adCheckService.refreshAdStatus();
//       }
//     }
//   }
//
//   Future<void> restorePurchases(bool isTrue) async {
//     isRestoringManually = isTrue;
//     if (isTrue) {
//       await _iap.restorePurchases();
//     } else {
//       if (isValidSubscription()) {
//         BotToast.showText(text: "Subscription already active");
//       } else {
//         await _iap.restorePurchases();
//       }
//     }
//   }
//
//   @override
//   void onClose() {
//     _subscription?.cancel();
//     super.onClose();
//   }
//
//   Future<void> purchaseSubscription() async {
//     final PurchaseParam purchaseParam = PurchaseParam(
//       productDetails: products[selectedPlan.value],
//     );
//
//     try {
//       bool success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//       if (!success) {
//         Get.snackbar("Purchase Failed", "Unable to complete purchase");
//       }
//     } catch (e) {
//       debugPrint("Purchase Error: $e");
//       Get.snackbar("Error", "Something went wrong");
//     }
//   }
// }
//
//
