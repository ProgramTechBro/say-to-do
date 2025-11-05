String cleanSubscriptionTitle(String title) {
  return title.replaceAll(RegExp(r'\s*\(.*?\)$'), '');
}