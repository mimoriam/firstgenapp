// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
//
// // It's better to load these from environment variables
// const _googleApiKey = 'googl_your_google_api_key'; // REPLACE WITH YOUR KEY
// const _appleApiKey = 'appl_your_apple_api_key'; // REPLACE WITH YOUR KEY
//
// class RevenueCatService {
//   static final RevenueCatService _instance = RevenueCatService._internal();
//   factory RevenueCatService() => _instance;
//   RevenueCatService._internal();
//
//   Future<void> init() async {
//     await Purchases.setLogLevel(LogLevel.debug);
//
//     PurchasesConfiguration configuration;
//     if (Platform.isAndroid) {
//       configuration = PurchasesConfiguration(_googleApiKey);
//     } else if (Platform.isIOS) {
//       configuration = PurchasesConfiguration(_appleApiKey);
//     } else {
//       return;
//     }
//     await Purchases.configure(configuration);
//   }
//
//   Future<void> login(String userId) async {
//     try {
//       await Purchases.logIn(userId);
//     } catch (e) {
//       log("Error logging into RevenueCat: $e");
//     }
//   }
//
//   Future<void> logout() async {
//     try {
//       await Purchases.logOut();
//     } catch (e) {
//       log("Error logging out of RevenueCat: $e");
//     }
//   }
//
//   Future<List<Offering>> getOfferings() async {
//     try {
//       final offerings = await Purchases.getOfferings();
//       return offerings.all.values.toList();
//     } catch (e) {
//       log("Error fetching offerings: $e");
//       return [];
//     }
//   }
//
//   Future<bool> purchasePackage(Package package) async {
//     try {
//       await Purchases.purchasePackage(package);
//       return true;
//     } on PlatformException catch (e) {
//       final purchasesErrorCode = PurchasesErrorHelper.getErrorCode(e);
//       if (purchasesErrorCode != PurchasesErrorCode.purchaseCancelledError) {
//         log("Error purchasing package: $e");
//       }
//       return false;
//     } catch (e) {
//       log("Error purchasing package: $e");
//       return false;
//     }
//   }
//
//   Future<void> restorePurchases() async {
//     try {
//       await Purchases.restorePurchases();
//     } catch (e) {
//       log("Error restoring purchases: $e");
//     }
//   }
// }
