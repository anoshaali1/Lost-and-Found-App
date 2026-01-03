import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final IconData? icon;

  const CustomField({
    super.key, 
    required this.controller, 
    required this.hint, 
    this.isPassword = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64FFDA).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF64FFDA)) : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF64FFDA), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF2D2D2D), width: 1.5),
          ),
        ),
      ),
    );
  }
}