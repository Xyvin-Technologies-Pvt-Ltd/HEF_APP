import 'package:url_launcher/url_launcher.dart';

void launchURL(String url) async {
  // Trim any whitespace from the start of the URL
  url = url.trimLeft();

  // Check if the URL starts with 'http://' or 'https://', if not add 'http://'
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'http://' + url;
  }

  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    print(e);
  }
}
Future<void> openGoogleMaps(String location) async {
  final Uri googleMapsUrl =
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$location");

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl);
  } else {
    print('Failed to load maps');
  }
}
