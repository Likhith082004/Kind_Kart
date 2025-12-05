import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  void _deleteProduct(String docId, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("electronics")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product deleted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Products")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("electronics")
            .where("sellerId", isEqualTo: userId)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text("You have not added any products yet."),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];

              return Card(
                child: ListTile(
                  title: Text(p["name"]),
                  subtitle: Text("₹ ${p["price"]} \nMobile: ${p["mobile"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(p.id, context),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
