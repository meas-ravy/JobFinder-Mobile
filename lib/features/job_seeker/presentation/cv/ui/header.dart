import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name
        const Text(
          'CONNOR HAMILTON',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Title
        const Text(
          'Real Estate Agent',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Contact Info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildContactItem('123-456-7890'),
            _buildSeparator(),
            _buildContactItem('hello@reallygreatsite.com'),
            _buildSeparator(),
            _buildContactItem('reallygreatsite.com'),
          ],
        ),
        const SizedBox(height: 20),

        // Divider
        Container(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}

Widget _buildContactItem(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 11, color: Colors.black54),
  );
}

Widget _buildSeparator() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Text('|', style: TextStyle(fontSize: 11, color: Colors.black54)),
  );
}
