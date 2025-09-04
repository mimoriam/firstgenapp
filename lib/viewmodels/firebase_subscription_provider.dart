// lib/viewmodels/firebase_subscription_provider.dart

import 'dart:async';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  StreamSubscription? _subscriptionStatusSubscription;

  // Added to explicitly track the user for this provider instance
  final String? userId;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  String? _subscriptionPlan;
  String? get subscriptionPlan => _subscriptionPlan;

  DateTime? _subscriptionEndDate;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SubscriptionProvider(this._firebaseService)
    : userId = _firebaseService.currentUser?.uid {
    _subscriptionStatusSubscription = _firebaseService
        .getSubscriptionStatusStream()
        .listen((status) {
          _isPremium = status?['isSubscribed'] ?? false;
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

  Future<bool> purchasePackage(String plan) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebaseService.subscribeUser(plan);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error purchasing package: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
