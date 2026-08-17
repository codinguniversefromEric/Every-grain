import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'app_logger.dart';

class IAPService extends ChangeNotifier {
  static final IAPService instance = IAPService._();

  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool isAvailable = false;
  List<ProductDetails> products = [];
  bool isLoading = false;
  
  // 這些 ID 必須和 Google Play Console 後台設定的完全一致
  final Set<String> _productIds = {
    'tip_jar_small',
    'tip_jar_medium',
    'tip_jar_large',
  };

  void initialize() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      AppLogger.e('IAP purchase stream error', error);
    });
    
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      AppLogger.w('Store not available');
      isLoading = false;
      notifyListeners();
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      AppLogger.e('Error loading products', response.error);
      isLoading = false;
      notifyListeners();
      return;
    }

    products = response.productDetails;
    isLoading = false;
    notifyListeners();
  }

  void buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 可以加上 Loading 狀態通知
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          AppLogger.e('Purchase error', purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          AppLogger.i('Purchase successful: ${purchaseDetails.productID}');
          // 這裡可以透過 Snackbar 感謝使用者，或寫入 SharedPreferences 記錄贊助次數
        }
        
        // 必須呼叫 completePurchase，否則商品會卡在 pending，後續無法再購買
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
