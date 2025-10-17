import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.048,
            fontFamily: 'Inter18'
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        children: [
          SizedBox(height: screenHeight * 0.01),
          Center(
            child: SvgPicture.asset(
              'assets/icons/settinglogo.svg',
              height: screenHeight * 0.12,
            ),
          ),
          SizedBox(height: screenHeight * 0.012),
          Center(
            child: Text(
              'Version 1.0.0 (Build 2025.07.07)',
              style: TextStyle(
                color: Color(0xFF535456),
                fontSize: screenWidth * 0.035,
                  fontFamily: 'Inter18'
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.012),
          Text(
            'SayToDo is your smart assistant for staying organized, focused, and productive.',
            // 'Your personal task management assistant to help you stay organized and productive.',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.038,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.012),
          Center(
            child: Text(
              '© 2025 SayToDo Inc. All rights reserved.',
              style: TextStyle(
                color: Color(0xFF535456),
                fontSize: screenWidth * 0.032,
                  fontFamily: 'Inter18'
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Development Team',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.042,
              color: Colors.black,
                fontFamily: 'Inter18'
            ),
          ),
          SizedBox(height: screenHeight * 0.012),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.018,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SayToDo was built by a passionate and diverse team of developers, designers, and QA engineers, united by a common goal — to make productivity effortless and enjoyable.',
                  // 'TaskMate is developed by a dedicated team of professionals committed to creating the best task management experience.',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: screenWidth * 0.036,
                  ),
                ),
                SizedBox(height: screenHeight * 0.012),
                Wrap(
                  spacing: screenWidth * 0.02,
                  runSpacing: screenHeight * 0.01,
                  children: [
                    _tag('Design', screenWidth),
                    _tag('Development', screenWidth),
                    _tag('Quality Assurance', screenWidth),
                    _tag('User Support', screenWidth),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Contact & Support',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.042,
              color: Colors.black,
              fontFamily: 'Inter18'
            ),
          ),
          SizedBox(height: screenHeight * 0.012),
          _contactRow(
            context,
            screenWidth,
            icon: Icons.email_outlined,
            text: 'support@saytodo.app',
          ),
          // SizedBox(height: screenHeight * 0.012),
          // _contactRow(
          //   context,
          //   screenWidth,
          //   icon: Icons.language,
          //   text: 'taskmate.app',
          // ),
          // SizedBox(height: screenHeight * 0.03),
          // Text(
          //   'Follow us on social media',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: screenWidth * 0.042,
          //     color: Colors.black,
          //       fontFamily: 'Inter18'
          //   ),
          // ),
          // SizedBox(height: screenHeight * 0.012),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _socialCircleIcon('assets/icons/twitter.svg', screenWidth),
          //     SizedBox(width: screenWidth * 0.04),
          //     _socialCircleIcon('assets/icons/instgram.svg', screenWidth),
          //     SizedBox(width: screenWidth * 0.04),
          //     _socialCircleIcon('assets/icons/facebook.svg', screenWidth),
          //     SizedBox(width: screenWidth * 0.04),
          //     _socialCircleIcon('assets/icons/linkedin.svg', screenWidth),
          //   ],
          // ),
          // SizedBox(height: screenHeight * 0.03),
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(
          //     horizontal: screenWidth * 0.04,
          //     vertical: screenHeight * 0.018,
          //   ),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(screenWidth * 0.04),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Enjoying TaskMate?',
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: screenWidth * 0.04,
          //           color: Colors.black,
          //             fontFamily: 'Inter18'
          //         ),
          //       ),
          //       SizedBox(height: screenHeight * 0.01),
          //       Text(
          //         'Your feedback helps us improve. Please consider rating our app.',
          //         style: TextStyle(
          //           color: Colors.grey[700],
          //           fontSize: screenWidth * 0.035,
          //         ),
          //       ),
          //       SizedBox(height: screenHeight * 0.012),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: List.generate(
          //           5,
          //           (i) => Padding(
          //             padding: EdgeInsets.only(right: screenWidth * 0.01),
          //             child: Icon(
          //               Icons.star_border,
          //               size: screenWidth * 0.07,
          //               color: Colors.grey[500],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }

  Widget _tag(String text, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE4E4E4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: screenWidth * 0.033,
        ),
      ),
    );
  }

  Widget _contactRow(
    BuildContext context,
    double screenWidth, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.038,
            ),
          ),
        ],
      ),
    );
  }


  Widget _socialCircleIcon(String asset, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Color(0xFFE4E4E4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SvgPicture.asset(
        asset,
        height: screenWidth * 0.06,
        width: screenWidth * 0.06,
      ),
    );
  }
}
