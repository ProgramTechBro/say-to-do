import 'package:first_project/screens/language_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/LanguageScreenController.dart';
class LanguagePickerBottomSheet extends StatelessWidget {
  final LanguageScreenController controller;

  const LanguagePickerBottomSheet({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final selectedLang = controller.selectedLanguage['title'];
    return Container(
      height: screenHeight * 0.45,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Language',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Inter18'),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 26, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: controller.filteredLanguages.length,
                itemBuilder: (context, index) {
                  final lang = controller.filteredLanguages[index];
                  final isSelected = lang['title'] == selectedLang;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          controller.setSelectedLanguage(lang);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lang['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter18'
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Color(0xFF6663F1),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
