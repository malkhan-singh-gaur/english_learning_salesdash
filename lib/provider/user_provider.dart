import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/models/order_model.dart';
import 'package:english_learning_sales/models/salesmanmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Provides the Firestore document for the currently logged-in salesman
final salesmanDataProvider = StreamProvider<SalesmanModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('salesmen')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists || snapshot.data() == null) return null;
            return SalesmanModel.fromJson(snapshot.data()!);
          });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// 1. Fetch all successful orders for the current salesman
final salesmanOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('orders')
      .where('salesmanUid', isEqualTo: user.uid)
      .where('paymentStatus', isEqualTo: 'Success')
      .orderBy('purchaseDate', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList(),
      );
});

// 2. Computed provider to calculate stats
final salesStatsProvider = Provider((ref) {
  final orders = ref.watch(salesmanOrdersProvider).value ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final startOfMonth = DateTime(now.year, now.month, 1);

  double dailyTotal = 0;
  double weeklyTotal = 0;
  double monthlyTotal = 0;

  for (var order in orders) {
    final date = order.purchaseDate.toDate();
    final amount = order.amountPaid;

    if (date.isAfter(today)) dailyTotal += amount;
    if (date.isAfter(startOfWeek)) weeklyTotal += amount;
    if (date.isAfter(startOfMonth)) monthlyTotal += amount;
  }

  return {
    'daily': dailyTotal,
    'weekly': weeklyTotal,
    'monthly': monthlyTotal,
    'totalOrders': orders.length,
    'recentOrders': orders.take(10).toList(), // For your table
  };
});
