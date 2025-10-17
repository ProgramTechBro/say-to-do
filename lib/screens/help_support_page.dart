import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int? expandedFaqIndex;

  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I create a new task?',
      'answer':
          'To create a new task, tap the plus (+) button at the bottom of the home screen.',
    },
    {
      'question': 'How do I edit a task?',
      'answer': 'Tap on a task to edit its details, then save your changes.',
    },
    {
      'question': 'How do I delete a task?',
      'answer': 'Swipe left on a task and tap the delete icon to remove it.',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

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
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.047,
            fontFamily: 'Inter18',
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
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
              color: Colors.black,
              fontFamily: 'Inter18',
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...List.generate(
            faqs.length,
            (index) => _faqItem(context, screenWidth, screenHeight, index),
          ),
          // SizedBox(height: screenHeight * 0.01),
          // GestureDetector(
          //   onTap: () {},
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          //     child: Row(
          //       children: [
          //         Text(
          //           'View all FAQs',
          //           style: TextStyle(
          //             color: Color(0xFF3CB371),
          //             fontWeight: FontWeight.w500,
          //             fontSize: screenWidth * 0.04,
          //             fontFamily: 'Inter18',
          //           ),
          //         ),
          //         SizedBox(width: screenWidth * 0.01),
          //         Icon(
          //           Icons.arrow_forward_ios,
          //           color: Color(0xFF3CB371),
          //           size: screenWidth * 0.04,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(height: screenHeight * 0.03),
          // Text(
          //   'Contact Support',
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: screenWidth * 0.045,
          //     fontFamily: 'Inter18',
          //     color: Colors.black,
          //   ),
          // ),
          // SizedBox(height: screenHeight * 0.02),
          // _contactSupportItem(
          //   context,
          //   screenWidth,
          //   screenHeight,
          //   svg: 'assets/icons/msg.svg',
          //   title: 'Live Chat',
          //   subtitle: 'Typical response time: 5 minutes',
          //   status: 'Online',
          //   statusColor: Color(0xFF4caf50),
          //   statusBg: Color(0xFFE4F3E5),
          //   iconBg: Color(0xFFE4F3E5),
          // ),
          // SizedBox(height: screenHeight * 0.018),
          // _contactSupportItem(
          //   context,
          //   screenWidth,
          //   screenHeight,
          //   svg: 'assets/icons/email.svg',
          //   title: 'Email Support',
          //   subtitle: 'Typical response time: 24 hours',
          //   iconBg: Color(0xFFDEEFFD),
          // ),
          // SizedBox(height: screenHeight * 0.018),
          // _contactSupportItem(
          //   context,
          //   screenWidth,
          //   screenHeight,
          //   svg: 'assets/icons/ticket.svg',
          //   title: 'Submit a Ticket',
          //   subtitle: 'For complex issues requiring investigation',
          //   iconBg: Color(0xFFF0DFF3),
          // ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget _faqItem(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    int index,
  ) {
    final isExpanded = expandedFaqIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedFaqIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.012),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    faqs[index]['question']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.04,
                      fontFamily: 'Inter18',
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                  size: screenWidth * 0.06,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.008),
            AnimatedCrossFade(
              firstChild: Text(
                faqs[index]['answer']!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                faqs[index]['answer']!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: screenWidth * 0.035,
                  fontFamily: 'Inter18',
                ),
              ),
              crossFadeState:
                  isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactSupportItem(
    BuildContext context,
    double screenWidth,
    double screenHeight, {
    required String svg,
    required String title,
    required String subtitle,
    String? status,
    Color? statusColor,
    Color? statusBg,
    Color? iconBg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.022,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenWidth * 0.12,
            width: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: iconBg ?? Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svg,
                height: screenWidth * 0.06,
                width: screenWidth * 0.06,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.042,
                        fontFamily: 'Inter18',
                        color: Colors.black,
                      ),
                    ),
                    if (status != null) ...[
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.025,
                          vertical: screenHeight * 0.004,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg ?? Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor ?? Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.032,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: screenHeight * 0.006),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.034,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
