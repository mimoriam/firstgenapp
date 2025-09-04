import 'dart:async';
import 'package:firstgenapp/services/firebase_service.dart';
// import 'package:firstgenapp/services/inapp_purchase_service.dart'; // Original service, commented out
import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart'; // Original package, commented out

class SubscriptionProvider extends ChangeNotifier {
  // --- START: Original RevenueCat implementation (Commented Out for simulation) ---
  //
  // This section contains the original code that would be used with a real
  // in-app purchase provider like RevenueCat. It is commented out to allow
  // for the manual Firestore-based subscription simulation as requested.

  // final RevenueCatService _revenueCatService;
  //
  // bool _isPremium = false;
  // bool get isPremium => _isPremium;
  //
  // List<Offering> _offerings = [];
  // List<Offering> get offerings => _offerings;
  //
  // bool _isLoading = false;
  // bool get isLoading => _isLoading;
  //
  // SubscriptionProvider(this._revenueCatService) {
  //   // Add the listener for customer info updates
  //   Purchases.addCustomerInfoUpdateListener(_updatePremiumStatus);
  //   // Check the initial status when the provider is created
  //   _checkInitialStatus();
  // }
  //
  // // Method to check the initial subscription status
  // Future<void> _checkInitialStatus() async {
  //   try {
  //     final customerInfo = await Purchases.getCustomerInfo();
  //     _updatePremiumStatus(customerInfo);
  //   } catch (e) {
  //     // Handle error fetching initial customer info
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   // Remove the listener when the provider is disposed
  //   Purchases.removeCustomerInfoUpdateListener(_updatePremiumStatus);
  //   super.dispose();
  // }
  //
  // void _updatePremiumStatus(CustomerInfo customerInfo) {
  //   // Assuming you have an entitlement called "premium" in RevenueCat
  //   final isSubscribed =
  //       customerInfo.entitlements.all["premium"]?.isActive ?? false;
  //   if (_isPremium != isSubscribed) {
  //     _isPremium = isSubscribed;
  //     notifyListeners();
  //   }
  // }
  //
  // Future<void> fetchOfferings() async {
  //   _isLoading = true;
  //   notifyListeners();
  //   _offerings = await _revenueCatService.getOfferings();
  //   _isLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<bool> purchasePackage(Package package) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   final success = await _revenueCatService.purchasePackage(package);
  //   _isLoading = false;
  //   notifyListeners();
  //   return success;
  // }
  // --- END: Original RevenueCat implementation ---

  // --- START: New Firebase Manual Subscription Logic ---
  // This new implementation uses FirebaseService to manually check and update
  // the user's subscription status in Firestore.

  final FirebaseService _firebaseService;
  StreamSubscription? _subscriptionStatusSubscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  // FIX: Added fields for plan and end date to hold the full subscription status.
  String? _subscriptionPlan;
  String? get subscriptionPlan => _subscriptionPlan;

  DateTime? _subscriptionEndDate;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// The constructor now takes `FirebaseService` and immediately starts listening
  /// to the user's subscription status.
  SubscriptionProvider(this._firebaseService) {
    // Listen to the user's subscription status from their Firestore document.
    // This stream-based approach ensures that the app's UI will react in real-time
    // to any changes in the subscription status (e.g., expiration).
    _subscriptionStatusSubscription = _firebaseService
        .getSubscriptionStatusStream()
        .listen((status) {
          _isPremium = status?['isSubscribed'] ?? false;
          // FIX: Update the plan and end date from the stream's map.
          _subscriptionPlan = status?['plan'];
          _subscriptionEndDate = status?['endDate'];
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _subscriptionStatusSubscription?.cancel();
    super.dispose();
  }

  /// Simulates a purchase by updating the user's subscription information in Firestore.
  /// This method is called from the UI when a user selects a subscription plan.
  /// [plan] should be a string, either 'monthly' or 'weekly'.
  Future<bool> purchasePackage(String plan) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.subscribeUser(plan);
      // After a successful update to Firestore, the stream listener will automatically
      // update the `_isPremium` status and notify listeners. We just need to handle the loading state.
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Handle any errors during the Firestore update
      print("Error purchasing package: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- END: New Firebase Manual Subscription Logic ---
}
