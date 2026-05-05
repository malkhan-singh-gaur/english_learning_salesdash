import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_learning_sales/models/sales_agent_model.dart'; // Updated Import
import 'package:english_learning_sales/pages/sales_agents/salesman_card.dart';
import 'package:english_learning_sales/pages/sales_agents/salesmen_order_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../ui_utils/my_custom_decorations.dart';
import 'create_salesman.dart';

class SalesmenListPage extends StatefulWidget {
  const SalesmenListPage({super.key});

  @override
  State<SalesmenListPage> createState() => _SalesmenListPageState();
}

class _SalesmenListPageState extends State<SalesmenListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Sales Agents Directory',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: MyCustomDecorations.inputDecoration(
                context,
                "Search by name...",
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.blueGrey.shade400,
                ),
              ),
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
            ),
          ),

          // List View
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salesmen')
                  .where(
                    'mySupervisor',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context, 'No agents found.');
                }

                var agents = snapshot.data!.docs
                    .map(
                      (doc) => SalesAgent.fromJson(
                        // Updated Model
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where(
                      (agent) => agent
                          .personalInfo
                          .fullName // Updated Field
                          .toLowerCase()
                          .contains(searchQuery),
                    )
                    .toList();

                if (agents.isEmpty) {
                  return _buildEmptyState(
                    context,
                    'No results match your search.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ).copyWith(bottom: 100), // padding for FAB
                  physics: const BouncingScrollPhysics(),
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    return SalesmanCard(agent: agents[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSalesmanPage()),
          );
        },
        backgroundColor: primaryColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Add Agent",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildMiniChip(
    BuildContext context,
    IconData icon,
    String label,
    MaterialColor color,
  ) {
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

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.group_off_outlined,
              size: 48,
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
