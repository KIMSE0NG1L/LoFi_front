import 'package:url_launcher/url_launcher.dart';

const String privacyPolicyUrl = 'https://guhaejo-web.vercel.app/privacy';
const String termsOfServiceUrl = 'https://guhaejo-web.vercel.app/terms';

Future<void> openPrivacyPolicy() async {
  await launchUrl(Uri.parse(privacyPolicyUrl), mode: LaunchMode.externalApplication);
}

Future<void> openTermsOfService() async {
  await launchUrl(Uri.parse(termsOfServiceUrl), mode: LaunchMode.externalApplication);
}
