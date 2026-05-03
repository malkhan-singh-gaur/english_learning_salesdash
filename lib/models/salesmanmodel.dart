import 'package:cloud_firestore/cloud_firestore.dart';

class SalesmanModel {
  final String uid;
  final String name;
  final String email;
  final int phoneNumber;
  final String referralCode;
  final bool isActive; // To disable access if they leave the company
  final double commissionRate; // e.g., 10.0 for 10%
  final String? profileImageUrl;
  final DateTime createdAt;

  SalesmanModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.referralCode,
    required this.isActive,
    required this.commissionRate,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory SalesmanModel.fromJson(Map<String, dynamic> json) {
    return SalesmanModel(
      uid: json['uid'] ?? json['agentId'],
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as int? ?? 0,
      referralCode: json['referralCode'] as String,
      isActive: json['isActive'] as bool? ?? true,
      commissionRate: (json['commissionRate'] as num? ?? 0.0).toDouble(),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'referralCode': referralCode,
      'isActive': isActive,
      'commissionRate': commissionRate,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
