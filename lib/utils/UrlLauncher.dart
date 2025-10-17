import 'package:url_launcher/url_launcher_string.dart';

Future<void> urlLauncher(String url) async {
  if (!await launchUrlString(url)) {
    throw Exception('Could not launch $url');
  }
}