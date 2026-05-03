import 'package:cloud_firestore/cloud_firestore.dart';

class SalesAgent {
  final String agentId;
  final String status; // 'active', 'inactive', 'terminated'
  final String referralCode;
  final Timestamp createdAt;
  final PersonalInfo personalInfo;
  final KycAndBankDetails kycAndBankDetails;
  final ContractTerms contractTerms;

  SalesAgent({
    required this.agentId,
    required this.status,
    required this.referralCode,
    required this.createdAt,
    required this.personalInfo,
    required this.kycAndBankDetails,
    required this.contractTerms,
  });

  factory SalesAgent.fromJson(Map<String, dynamic> json) {
    return SalesAgent(
      agentId: json['agentId'] ?? '',
      status: json['status'] ?? 'inactive',
      referralCode: json['referralCode'] ?? '',
      // Handle Firebase Timestamp or standard ISO 8601 string
      createdAt: json['createdAt'] != null && json['createdAt'] is String
          ? json['createdAt']
          : (json['createdAt'] ?? Timestamp.now()),
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      kycAndBankDetails: KycAndBankDetails.fromJson(json['kycAndBankDetails'] ?? {}),
      contractTerms: ContractTerms.fromJson(json['contractTerms'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'status': status,
      'referralCode': referralCode,
      'createdAt': createdAt,
      'personalInfo': personalInfo.toJson(),
      'kycAndBankDetails': kycAndBankDetails.toJson(),
      'contractTerms': contractTerms.toJson(),
    };
  }
}

class PersonalInfo {
  final String fullName;
  final String phone;
  final String email;
  final String? profileImageUrl;

  PersonalInfo({
    required this.fullName,
    required this.phone,
    required this.email,
    this.profileImageUrl,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }
}

class KycAndBankDetails {
  final String aadhaarNumber;
  final String panNumber;
  final String bankAccountNumber;
  final String ifscCode;
  final bool isKycVerified;
  final String? documentPdfLink; // Added PDF link for agreement/documents

  KycAndBankDetails({
    required this.aadhaarNumber,
    required this.panNumber,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.isKycVerified,
    this.documentPdfLink,
  });

  factory KycAndBankDetails.fromJson(Map<String, dynamic> json) {
    return KycAndBankDetails(
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      isKycVerified: json['isKycVerified'] ?? false,
      documentPdfLink: json['documentPdfLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'isKycVerified': isKycVerified,
      if (documentPdfLink != null) 'documentPdfLink': documentPdfLink,
    };
  }
}

class ContractTerms {
  final int monthlyTarget;
  final double baseTargetPayout;
  final double belowTargetPerSale;
  final double bonusPerSale;
  final int consecutiveMonthsMissed;

  ContractTerms({
    required this.monthlyTarget,
    required this.baseTargetPayout,
    required this.belowTargetPerSale,
    required this.bonusPerSale,
    required this.consecutiveMonthsMissed,
  });

  factory ContractTerms.fromJson(Map<String, dynamic> json) {
    return ContractTerms(
      monthlyTarget: json['monthlyTarget']?.toInt() ?? 15,
      baseTargetPayout: json['baseTargetPayout']?.toDouble() ?? 8000.0,
      belowTargetPerSale: json['belowTargetPerSale']?.toDouble() ?? 500.0,
      bonusPerSale: json['bonusPerSale']?.toDouble() ?? 300.0,
      consecutiveMonthsMissed: json['consecutiveMonthsMissed']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyTarget': monthlyTarget,
      'baseTargetPayout': baseTargetPayout,
      'belowTargetPerSale': belowTargetPerSale,
      'bonusPerSale': bonusPerSale,
      'consecutiveMonthsMissed': consecutiveMonthsMissed,
    };
  }
}