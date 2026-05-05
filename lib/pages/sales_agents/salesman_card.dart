import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/pages/sales_agents/salesmen_order_page.dart';
import 'package:flutter/material.dart';

import '../../models/sales_agent_model.dart';
import '../../ui_utils/my_custom_decorations.dart';

class SalesmanCard extends StatefulWidget {
  final SalesAgent agent;

  const SalesmanCard({super.key, required this.agent});

  @override
  State<SalesmanCard> createState() => _SalesmanCardState();
}

class _SalesmanCardState extends State<SalesmanCard> {
  int orderCount = 0;
  bool isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderCount();
  }

  Future<void> _fetchOrderCount() async {
    try {
      // Using count() is cheaper and faster than fetching all documents
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('salesmanUid', isEqualTo: widget.agent.agentId) // Adjust 'uid' if your model uses a different ID field
          .count()
          .get();

      if (mounted) {
        setState(() {
          orderCount = snapshot.count ?? 0;
          isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingOrders = false);
      }
      debugPrint("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isActive = widget.agent.status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: MyCustomDecorations.cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SalesmanOrdersPage(salesman: widget.agent),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    widget.agent.personalInfo.fullName.isNotEmpty
                        ? widget.agent.personalInfo.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.agent.personalInfo.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildMiniChip(
                            Icons.local_offer_rounded,
                            widget.agent.referralCode,
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildMiniChip(
                            Icons.track_changes_rounded,
                            "Target: ${widget.agent.contractTerms.monthlyTarget}",
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status & Trailing Orders
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Orders Count Widget
                    isLoadingOrders
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      "$orderCount Orders",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
}