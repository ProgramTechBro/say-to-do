import 'package:flutter/material.dart';

import '../controllers/PremiumController.dart';
import 'package:get/get.dart';
class PremiumScreen extends StatelessWidget {
  PremiumScreen({Key? key}) : super(key: key);

  final PremiumController controller = Get.put(PremiumController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final fromNamed = Get.arguments != null && Get.arguments['fromNamed'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: fromNamed
            ? null
            : IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Plans',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            fontFamily: 'Inter18'
          ),
        ),
        actions: fromNamed
            ? [
          TextButton(
            onPressed: () => Get.offAllNamed('/main'),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
                fontFamily: 'Inter18'
              ),
            ),
          ),
        ]
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Premium Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.9),
                              primaryColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                  fontFamily: 'Inter18'
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              'Simplify your journey with faster logging tools and custom settings',
                              style: TextStyle(
                                fontSize: screenWidth * 0.037,
                                fontFamily: 'Inter18',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    child: Obx(
                          () => GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: screenWidth * 0.02,
                        mainAxisSpacing: screenHeight * 0.015,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: screenWidth / (screenHeight * 0.28),
                        children: [
                          _buildPlanOption(
                            plan: 1,
                            isSelected: controller.selectedPlan.value == 1,
                            duration: '1 month',
                            price: '29.98/mo',
                            subText: 'Billed monthly',
                            primaryColor: primaryColor,
                            w: screenWidth,
                            h: screenHeight,
                            onTap: () => controller.selectPlan(1),
                          ),
                          _buildPlanOption(
                            plan: 2,
                            isSelected: controller.selectedPlan.value == 2,
                            duration: '12 months',
                            price: '9.92/mo',
                            subText: '118.98 billed annually',
                            primaryColor: primaryColor,
                            w: screenWidth,
                            h: screenHeight,
                            isYearly: true,
                            onTap: () => controller.selectPlan(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                      SizedBox(height: screenHeight * 0.025),

                      Text(
                        'Premium helps you:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                            fontFamily: 'Inter18'
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Features
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.025),
                        child: Column(
                          children: [
                            _featureTile(Icons.block, 'Go ad-free', 'Stay focused on your journey', screenWidth),
                            _featureTile(Icons.qr_code_scanner, 'Log food faster', 'Barcode and multi-day logging make it easy', screenWidth),
                            _featureTile(Icons.fastfood, 'Log entire meals at once', 'With meal scan and voice logging', screenWidth),
                            _featureTile(Icons.tune, 'Customize your goals', 'Flexible calorie and macro settings', screenWidth),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Trial Button
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.065,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Start 30-day free trial',
                            style: TextStyle(
                              fontSize: screenWidth * 0.043,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                                fontFamily: 'Inter18'
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),

                      // Bottom Info
                      Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: Text(
                          'Billing starts at the end of your free trial unless you cancel. Plans renew automatically. Cancel via the App Store.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.black54,
                              fontFamily: 'Inter18'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildPlanOption({
    required int plan,
    required bool isSelected,
    required String duration,
    required String price,
    required String subText,
    required Color primaryColor,
    required double w,
    required double h,
    required VoidCallback onTap,
    bool isYearly = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: w * 0.02),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(duration, style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.04,fontFamily: 'Inter18')),
                  Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.045,fontFamily: 'Inter18')),
                  Text(subText, textAlign: TextAlign.center, style: TextStyle(fontSize: w * 0.03, color: Colors.black54,fontFamily: 'Inter18')),
                ],
              ),
            ),
          ),
          if (isYearly)
            Positioned(
              top: -h * 0.01,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: h * 0.004),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Save 67%',
                    style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



  Widget _featureTile(IconData icon, String title, String subtitle, double w) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.015),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: w * 0.06),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: w * 0.042,fontFamily: 'Inter18')),
                SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: w * 0.032)),
              ],
            ),
          ),
        ],
      ),
    );
  }
