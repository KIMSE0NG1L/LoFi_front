import 'package:url_launcher/url_launcher.dart';

const String privacyPolicyUrl = 'https://guhaejo-web.vercel.app/privacy';

Future<void> openPrivacyPolicy() async {
  await launchUrl(Uri.parse(privacyPolicyUrl), mode: LaunchMode.externalApplication);
}
