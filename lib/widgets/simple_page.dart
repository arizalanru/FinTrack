import 'package:flutter/material.dart';

Widget simplePage(BuildContext context, String title, String content) {
  return Scaffold(
    backgroundColor: const Color(0xFFF2F2F2),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          content,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
    ),
  );
}
