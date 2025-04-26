import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String initialName;
  final String initialImageUrl;
  final String initialFont;
  final Function(String, String, String) onProfileUpdated;

  const ProfilePage({
    super.key,
    required this.initialName,
    required this.initialImageUrl,
    required this.initialFont,
    required this.onProfileUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  late String _imagePath; // Supports file path or network URL
  late String _font;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _imagePath = widget.initialImageUrl;
    _font = widget.initialFont;
  }

  void _navigateToEditPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          currentName: _name,
          currentImageUrl: _imagePath,
          currentFont: _font,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _name = result['name'] ?? _name;
        _imagePath = result['imageUrl'] ?? _imagePath;
        _font = result['font'] ?? _font;
      });

      widget.onProfileUpdated(_name, _imagePath, _font);
    }
  }

  Widget _buildProfileImage() {
    if (_imagePath.startsWith('http')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_imagePath),
        radius: 50,
        onBackgroundImageError: (_, __) =>
            const Icon(Icons.broken_image, size: 50),
      );
    } else if (File(_imagePath).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(_imagePath)),
        radius: 50,
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayFont = GoogleFonts.getFont(_font);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditPage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 20),
            Text(
              _name,
              style: displayFont.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              "Using font: $_font",
              style: TextStyle(fontFamily: _font),
            ),
          ],
        ),
      ),
    );
  }
}
