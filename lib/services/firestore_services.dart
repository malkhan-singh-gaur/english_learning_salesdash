import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/models/salesmanmodel.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Create ---
  /// Called when a new salesman is registered
  Future<void> createSalesman(SalesmanModel salesman) async {
    await _db.collection('salesmen').doc(salesman.uid).set(salesman.toJson());
  }

  // --- Read ---
  /// Gets a single salesman's data as a stream (real-time)
  Stream<SalesmanModel?> streamSalesman(String uid) {
    return _db.collection('salesmen').doc(uid).snapshots().map((snap) {
      if (snap.exists && snap.data() != null) {
        return SalesmanModel.fromJson(snap.data()!);
      }
      return null;
    });
  }

  /// Gets a salesman's data once (useful for one-time checks)
  Future<SalesmanModel?> getSalesman(String uid) async {
    final doc = await _db.collection('salesmen').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return SalesmanModel.fromJson(doc.data()!);
    }
    return null;
  }

  // --- Update ---
  /// Updates specific fields like name, phone, or profile image
  Future<void> updateSalesman(String uid, Map<String, dynamic> data) async {
    await _db.collection('salesmen').doc(uid).update(data);
  }

  /// Toggle active status (admin use case)
  Future<void> setSalesmanStatus(String uid, bool isActive) async {
    await _db.collection('salesmen').doc(uid).update({'isActive': isActive});
  }

  Future<void> uploadMockOrders(String salesmanUid, String referralCode) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    List<Map<String, dynamic>> mockOrders = [
      // Today
      {
        "orderId": "ORD_001",
        "userId": "user_alpha",
        "batchId": "batch_jan",
        "batchName": "English Fluency Pro",
        "amountPaid": 2500.0,
        "taxAmount": 450.0,
        "referralCodeUsed": referralCode,
        "salesmanUid": salesmanUid,
        "paymentStatus": "Success",
        "transactionId": "TXN_101",
        "purchaseDate": Timestamp.fromDate(
          now.subtract(const Duration(hours: 2)),
        ),
        "paymentMethod": "UPI",
      },
      // This Week
      {
        "orderId": "ORD_002",
        "userId": "user_beta",
        "batchId": "batch_feb",
        "batchName": "IELTS Mastery",
        "amountPaid": 5000.0,
        "taxAmount": 900.0,
        "referralCodeUsed": referralCode,
        "salesmanUid": salesmanUid,
        "paymentStatus": "Success",
        "transactionId": "TXN_102",
        "purchaseDate": Timestamp.fromDate(
          now.subtract(const Duration(days: 3)),
        ),
        "paymentMethod": "Card",
      },
      // This Month
      {
        "orderId": "ORD_003",
        "userId": "user_gamma",
        "batchId": "batch_jan",
        "batchName": "English Fluency Pro",
        "amountPaid": 2500.0,
        "taxAmount": 450.0,
        "referralCodeUsed": referralCode,
        "salesmanUid": salesmanUid,
        "paymentStatus": "Success",
        "transactionId": "TXN_103",
        "purchaseDate": Timestamp.fromDate(
          now.subtract(const Duration(days: 15)),
        ),
        "paymentMethod": "UPI",
      },
      // Failed Order (Should not count in stats)
      {
        "orderId": "ORD_004",
        "userId": "user_delta",
        "batchId": "batch_feb",
        "batchName": "IELTS Mastery",
        "amountPaid": 5000.0,
        "taxAmount": 900.0,
        "referralCodeUsed": referralCode,
        "salesmanUid": salesmanUid,
        "paymentStatus": "Failed",
        "transactionId": "TXN_104",
        "purchaseDate": Timestamp.fromDate(now),
        "paymentMethod": "UPI",
      },
    ];

    for (var order in mockOrders) {
      await firestore.collection('orders').doc(order['orderId']).set(order);
    }
    print("Mock orders uploaded successfully!");
  }
}
