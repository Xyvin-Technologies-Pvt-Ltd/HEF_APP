  Map<String, String> extractLevelDetails(String input) {
    final regex =
        RegExp(r"^(.*?) State (.*?) Zone (.*?) District (.*?) Chapter$");

    final match = regex.firstMatch(input);

    if (match != null) {
      return {
        "stateName": match.group(1)?.trim() ?? "",
        "zoneName": match.group(2)?.trim() ?? "",
        "districtName": match.group(3)?.trim() ?? "",
        "chapterName": match.group(4)?.trim() ?? "",
      };
    } else {
      throw ArgumentError("Input string does not match the expected format.");
    }
  }
