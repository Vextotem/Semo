import "dart:async";
import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:flutter_settings_ui/flutter_settings_ui.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:semo/bloc/app_bloc.dart";
import "package:semo/bloc/app_event.dart";
import "package:semo/components/snack_bar.dart";
import "package:semo/gen/assets.gen.dart";
import "package:semo/screens/base_screen.dart";
import "package:semo/screens/landing_screen.dart";
import "package:semo/models/streaming_server.dart";
import "package:semo/screens/open_source_libraries_screen.dart";
import "package:semo/services/auth_service.dart";
import "package:semo/services/streams_extractor_service/streams_extractor_service.dart";
import "package:semo/services/app_preferences_service.dart";
import "package:url_launcher/url_launcher.dart";

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key});

  @override
  BaseScreenState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseScreenState<SettingsScreen> {
  final AppPreferencesService _appPreferences = AppPreferencesService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  Future<void> _openAbout() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    if (mounted) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Container(
          width: double.infinity,
          margin: const EdgeInsets.all(18),
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Assets.images.appIcon.image(
                  width: 125,
                  height: 125,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayMedium,
                      children: <TextSpan>[
                        const TextSpan(text: "Developed by "),
                        TextSpan(
                          text: "Cineby",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(
                                Uri.parse("https://cineby.cc"),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        version,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        " · ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await launchUrl(
                            Uri.parse("https://cineby.cc"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Text(
                          "cineby.cc",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  String get screenName => "Settings";

  @override
  Widget buildContent(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildUserCard(),
                _buildSettingsList(),
              ],
            ),
          ),
        ),
      );

  // ⬇️ Everything below this line is UNCHANGED
  // (kept exactly as in your original file)

  Widget _buildUserCard() {
    String photoUrl = _auth.currentUser?.photoURL ?? "";
    String name = _auth.currentUser?.displayName ?? "User";
    String email = _auth.currentUser?.email ?? "user@email.com";

    return Container(
      margin: const EdgeInsets.only(top: 18, left: 18, right: 18),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              child: photoUrl.isEmpty
                  ? Icon(Icons.account_circle, color: Theme.of(context).primaryColor)
                  : CachedNetworkImage(
                      imageUrl: photoUrl,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      imageBuilder: (_, image) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          image: DecorationImage(image: image, fit: BoxFit.cover),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: Theme.of(context).textTheme.displayLarge),
                  Text(
                    email,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
