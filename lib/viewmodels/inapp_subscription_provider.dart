import 'dart:async';
import 'package:firstgenapp/services/inapp_purchase_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  List<Offering> _offerings = [];
  List<Offering> get offerings => _offerings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider(this._revenueCatService) {
    // Add the listener for customer info updates
    Purchases.addCustomerInfoUpdateListener(_updatePremiumStatus);
    // Check the initial status when the provider is created
    _checkInitialStatus();
  }

  // Method to check the initial subscription status
  Future<void> _checkInitialStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      // Handle error fetching initial customer info
    }
  }

  @override
  void dispose() {
    // Remove the listener when the provider is disposed
    Purchases.removeCustomerInfoUpdateListener(_updatePremiumStatus);
    super.dispose();
  }

  void _updatePremiumStatus(CustomerInfo customerInfo) {
    // Assuming you have an entitlement called "premium" in RevenueCat
    final isSubscribed =
        customerInfo.entitlements.all["premium"]?.isActive ?? false;
    if (_isPremium != isSubscribed) {
      _isPremium = isSubscribed;
      notifyListeners();
    }
  }

  Future<void> fetchOfferings() async {
    _isLoading = true;
    notifyListeners();
    _offerings = await _revenueCatService.getOfferings();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> purchasePackage(Package package) async {
    _isLoading = true;
    notifyListeners();
    final success = await _revenueCatService.purchasePackage(package);
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
