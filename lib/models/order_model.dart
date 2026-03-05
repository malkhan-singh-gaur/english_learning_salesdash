import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String batchId;
  final String batchName;
  final double amountPaid;
  final double taxAmount;
  final String referralCodeUsed;
  final String salesmanUid;
  final String paymentStatus; // e.g., "Pending", "Success", "Failed"
  final String transactionId; // From Payment Gateway (Razorpay/Stripe)
  final Timestamp purchaseDate;
  final String paymentMethod; // e.g., "UPI", "Card"

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.batchId,
    required this.batchName,
    required this.amountPaid,
    required this.taxAmount,
    required this.referralCodeUsed,
    required this.salesmanUid,
    required this.paymentStatus,
    required this.transactionId,
    required this.purchaseDate,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String,
      userId: json['userId'] as String,
      batchId: json['batchId'] as String,
      batchName: json['batchName'] as String,
      amountPaid: (json['amountPaid'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      referralCodeUsed: json['referralCodeUsed'] as String,
      salesmanUid: json['salesmanUid'] as String,
      paymentStatus: json['paymentStatus'] as String,
      transactionId: json['transactionId'] as String,
      purchaseDate: json['purchaseDate'] as Timestamp,
      paymentMethod: json['paymentMethod'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'batchId': batchId,
      'batchName': batchName,
      'amountPaid': amountPaid,
      'taxAmount': taxAmount,
      'referralCodeUsed': referralCodeUsed,
      'salesmanUid': salesmanUid,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
      'purchaseDate': purchaseDate,
      'paymentMethod': paymentMethod,
    };
  }
}
