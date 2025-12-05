import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _mobileController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(); // ⭐ NEW FIELD

  bool _isUploading = false;

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _locationController.text.isEmpty) { // ⭐ location required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await FirebaseFirestore.instance.collection("electronics").add({
        "name": _nameController.text.trim(),
        "price": _priceController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "description": _descriptionController.text.trim(),
        "location": _locationController.text.trim(), // ⭐ LOCATION SAVED
        "sellerId": FirebaseAuth.instance.currentUser!.uid,
        "timestamp": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _mobileController,
                decoration:
                    const InputDecoration(labelText: "Seller Mobile Number"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _locationController, // ⭐ LOCATION FIELD
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),

              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text("Add Product"),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
