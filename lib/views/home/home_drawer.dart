import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jhatpat/constants/app_constants.dart';
import 'package:jhatpat/services/providers/otp_screen_provider.dart';
import 'package:jhatpat/services/providers/profile_updated_provider.dart';
import 'package:jhatpat/models/user_model.dart';
import 'package:jhatpat/services/api/api_service.dart';
import 'package:jhatpat/services/shared_pref/shared_pref.dart';
import 'package:jhatpat/shared/loading.dart';
import 'package:jhatpat/shared/snackbar.dart';
import 'package:jhatpat/views/about/about.dart';
import 'package:jhatpat/views/history/history.dart';
import 'package:jhatpat/views/payment/promos.dart';
import 'package:jhatpat/views/profile/profile.dart';
import 'package:jhatpat/views/payment/subscription.dart';
import 'package:jhatpat/views/support/support.dart';
import 'package:jhatpat/wrapper.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> {
  bool loading = true;
  bool signingOut = false;
  bool userProfileComplete = false;
  bool errorLoadingProfile = false;
  UserProfileData? userProfileData;
  final TextStyle _sectionStyle = const TextStyle(color: Colors.white70);
  final Color _sideLogoCol = Colors.white70;

  @override
  void initState() {
    super.initState();
    ref.read(profileUpdated)
        ? checkUserData().whenComplete(() => setState((() {
              loading = false;
              ref.read(profileUpdated.state).state == false;
            })))
        : setState(() => loading = false);
  }

  Future checkUserData() async {
    try {
      userProfileData =
          await DatabaseService(token: UserSharedPreferences.getUserToken())
              .getProfileDetails();

      if (userProfileData!.name != null) {
        setState(() => userProfileComplete = true);
      }
    } catch (e) {
      if (e.toString() == "Invalid Token") {
        signOutMethod();
      }
      if (mounted) {
        showSnackBar(context: context, content: "$e");
        setState(() => errorLoadingProfile = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.red.shade700),
                    child: !loading
                        ? !errorLoadingProfile
                            ? userProfileComplete
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        maxRadius: 38.0,
                                        backgroundColor: Colors.black,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: userProfileData!.image == null
                                              ? Image.asset(
                                                  AppConstants
                                                      .defaultUserAvatarAssetPath,
                                                  fit: BoxFit.contain,
                                                )
                                              : CachedNetworkImage(
                                                  fit: BoxFit.contain,
                                                  imageUrl:
                                                      "${AppConstants.userStorageApiUrl}${userProfileData!.image!}",
                                                  placeholder: (context, url) =>
                                                      const CupertinoActivityIndicator(
                                                    color: Colors.white,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Image.asset(
                                                    AppConstants
                                                        .defaultUserAvatarAssetPath,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat"),
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text:
                                                  "\n${userProfileData!.name!}",
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text:
                                                  "\n+91${userProfileData!.phone!}",
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CircleAvatar(
                                        maxRadius: 38.0,
                                        backgroundImage: Image.asset(
                                                AppConstants
                                                    .defaultUserAvatarAssetPath)
                                            .image,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  const ProfilePage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Complete your profile",
                                          style: TextStyle(
                                              color: Colors.blue.shade100,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                            : const Icon(Icons.error,
                                size: 50.0, color: Colors.white54)
                        : const Loading(white: true),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: _sideLogoCol),
                  title: Text("Profile", style: _sectionStyle),
                  onTap: () {
                    if (!userProfileComplete) {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => const ProfilePage(),
                      ));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.card_membership, color: _sideLogoCol),
                  title: Text(
                    "Subscription Plans",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const SubscriptionPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, color: _sideLogoCol),
                  title: Text(
                    "History",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_offer, color: _sideLogoCol),
                  title: Text(
                    "Promotionals",
                    style: _sectionStyle,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const PromotionalsPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.support_agent, color: _sideLogoCol),
                  title: Text("Online Support", style: _sectionStyle),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const SupportPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info, color: _sideLogoCol),
                  title: Text("About", style: _sectionStyle),
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => const AboutPage()),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.power_settings_new, color: _sideLogoCol),
                  title: !signingOut
                      ? Text(
                          "Log Out",
                          style: _sectionStyle,
                        )
                      : const Loading(white: true),
                  onTap: () => signOutMethod(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signOutMethod() async {
    setState(() => signingOut = true);
    try {
      UserSharedPreferences.setLoggedInOrNot(false)
          .whenComplete(() => UserSharedPreferences.setUserToken(""))
          .whenComplete(() => UserSharedPreferences.setUserPhoneNum(""))
          .whenComplete(
              () => ref.read(otpScreenBoolProvider.state).state = false);
      await Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(builder: (context) => const WrapperPage()),
          (route) => false);
    } catch (e) {
      showSnackBar(
          context: context,
          content: "Something went wrong, couldn't properly sign-out");
    }
    setState(() => signingOut = false);
  }
}
