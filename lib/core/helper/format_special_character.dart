  // Helper to fix special characters like smart quotes (i'm, etc.)
  String cleanText(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-');
  }