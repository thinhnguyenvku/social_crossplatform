import 'package:flutter/material.dart';
import 'package:social_crossplatform/features/feed/screens/feed_screen.dart';
import 'package:social_crossplatform/features/post/screens/add_post_screen.dart';

class Constants {
  static const logoPath = 'assets/images/LOGO33.png';
  static const loginEmotePath = 'assets/images/LOGO3.png';
  static const googlePath = 'assets/images/google.png';
  static const bannerDefault =
      'https://upload.wikimedia.org/wikivoyage/zh/6/6a/Default_Banner.jpg';
  static const avatarDefault =
      'https://cdn.icon-icons.com/icons2/1371/PNG/512/robot02_90810.png';

  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
  ];

  static const IconData up =
      IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down =
      IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
