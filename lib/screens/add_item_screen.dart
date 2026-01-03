import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../services/local_image_service.dart';
import '../widgets/custom_field.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _regNoController = TextEditingController();
  final _deptController = TextEditingController();
  final _semesterController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCategory = 'Others'; // Default value
  String _selectedType = 'lost'; 
  String? _localImagePath;
  bool _isLoading = false;

  final List<String> _categories = ['Keys', 'Books', 'Electronics', 'ID Cards', 'Accessories', 'Others'];

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      String? savedPath = await LocalImageService.saveImage(File(pickedFile.path));
      if (savedPath != null) {
        setState(() => _localImagePath = savedPath);
      }
    }
  }

  void _submitItem() async {
    if (_nameController.text.isEmpty || _regNoController.text.isEmpty || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Name, Reg No, and Contact")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final User? user = FirebaseAuth.instance.currentUser;
    String finalName = user?.displayName ?? "Unknown Student";

    final newItem = ItemModel(
      name: _nameController.text.trim(),
      regNo: _regNoController.text.trim(),
      department: _deptController.text.trim(),
      semester: _semesterController.text.trim(),
      colorBrand: _colorController.text.trim(),
      details: _detailsController.text.trim(),
      category: _selectedCategory, // Correctly using the dropdown value
      location: _locationController.text.trim(),
      contact: _contactController.text.trim(),
      type: _selectedType,
      imagePath: _localImagePath ?? "",
      ownerId: user?.uid ?? 'anonymous',
      ownerName: finalName,
      createdAt: DateTime.now(),
      status: 'active',
    );

    try {
      await FirestoreService().addItem(newItem);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Posted Successfully!"), backgroundColor: Color(0xFF64FFDA)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Post New Item", style: TextStyle(color: Color(0xFF64FFDA))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickAndSaveImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF64FFDA).withOpacity(0.5), width: 1),
                ),
                child: _localImagePath == null 
                  ? const Icon(Icons.add_a_photo, color: Color(0xFF64FFDA), size: 40)
                  : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_localImagePath!), fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 20),

            // Type Selection
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("LOST")),
                    selected: _selectedType == 'lost',
                    selectedColor: const Color(0xFF64FFDA),
                    onSelected: (val) => setState(() => _selectedType = 'lost'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("FOUND")),
                    selected: _selectedType == 'found',
                    selectedColor: const Color(0xFF64FFDA),
                    onSelected: (val) => setState(() => _selectedType = 'found'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Dropdown (NEW)
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Select Category",
                labelStyle: const TextStyle(color: Color(0xFF64FFDA)),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 15),

            CustomField(controller: _nameController, hint: "Item Name (e.g., iPhone 13)"),
            const SizedBox(height: 15),
            CustomField(controller: _colorController, hint: "Color & Brand"),
            const SizedBox(height: 15),
            CustomField(controller: _regNoController, hint: "Your Reg No"),
            const SizedBox(height: 15),
            CustomField(controller: _deptController, hint: "Department"),
            const SizedBox(height: 15),
            CustomField(controller: _semesterController, hint: "Semester"),
            const SizedBox(height: 15),
            CustomField(controller: _locationController, hint: "Location Found/Lost"),
            const SizedBox(height: 15),
            CustomField(controller: _contactController, hint: "Contact (WhatsApp/Phone)"),
            const SizedBox(height: 15),

            TextField(
              controller: _detailsController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Specific Details (Scratches, specific case, etc.)",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            _isLoading 
              ? const CircularProgressIndicator(color: Color(0xFF64FFDA))
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64FFDA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitItem, 
                    child: const Text("SUBMIT POST", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}