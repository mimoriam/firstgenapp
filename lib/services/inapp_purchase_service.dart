import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Use your RevenueCat API keys
const _googleApiKey = 'AIzaSyDj3slusUFe6P7etN0DTDzsngsNSX3TdD8'; // REPLACE WITH YOUR KEY
const _appleApiKey = 'appl_your_apple_api_key'; // REPLACE WITH YOUR KEY

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    // Platform specific configuration is handled by RevenueCat
    PurchasesConfiguration configuration = PurchasesConfiguration(_googleApiKey)
      ..appUserID = null;
    await Purchases.configure(configuration);
  }

  Future<void> login(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      log("Error logging into RevenueCat: $e");
    }
  }

  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      log("Error logging out of RevenueCat: $e");
    }
  }

  Future<List<Offering>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all.values.toList();
    } catch (e) {
      log("Error fetching offerings: $e");
      return [];
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } on PlatformException catch (e) {
      final purchasesErrorCode = PurchasesErrorHelper.getErrorCode(e);
      if (purchasesErrorCode != PurchasesErrorCode.purchaseCancelledError) {
        log("Error purchasing package: $e");
      }
      return false;
    } catch (e) {
      log("Error purchasing package: $e");
      return false;
    }
  }
}
