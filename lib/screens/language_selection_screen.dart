import 'package:country_flags/country_flags.dart';
import 'package:double_tap_to_exit/double_tap_to_exit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/LanguageScreenController.dart';
import '../utils/Common.dart';
import '../utils/constants.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageScreenController controller =
      Get.find<LanguageScreenController>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return DoubleTapToExit(
      snackBar: SnackBar(
        content: Text(
          'Double tap to exit the app',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(screenWidth * 0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text(
            'Select Language',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter18',
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20,
              ),
              child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter18',
                ),
                onChanged: controller.filterLanguages,
                decoration: InputDecoration(
                  hintText: 'Search any language...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontFamily: 'Inter18',
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black38),
                  filled: true,
                  fillColor: Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.filteredLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = controller.filteredLanguages[index];
                    return Obx(() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: GestureDetector(
                            //borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.setSelectedLanguage(lang);
                            },
                            child: Container(
                              height: 48,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFEFF1F3), width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CountryFlag.fromCountryCode(
                                    getCountryCodeFromLanguage(lang['code'] ?? 'en'),
                                    width: 26,
                                    height: 26,
                                    shape: const Circle(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lang['title']!,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        fontFamily: 'Inter18',
                                      ),
                                    ),
                                  ),
                                  // if (isSelected)
                                  //   const Icon(Icons.check, color: Colors.blue),
                                  Radio<String>(
                                    value: lang['code'] ?? '',
                                    groupValue:
                                        controller.selectedLanguage['code'],
                                    onChanged: (val) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      controller.setSelectedLanguage(lang);
                                    },
                                    fillColor:
                                        MaterialStateProperty.resolveWith<
                                          Color
                                        >((states) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Color(0xFF6663F1);
                                          }
                                          return Color(0xFFE9ECEF);
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
            Container(
              color: Colors.white,
              // padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 12),
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    // await controller.saveLanguageSelection();
                    // Get.offAllNamed('/premium', arguments: {'fromNamed': true});
                    Get.offAllNamed('/main');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.017,
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.manrope(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
