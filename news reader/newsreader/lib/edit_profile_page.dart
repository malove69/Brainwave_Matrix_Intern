import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentImageUrl;
  final String currentFont;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentImageUrl,
    required this.currentFont,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  String _selectedImageUrl = '';
  String _selectedFont = 'Roboto';

  final List<String> _fontOptions = [
    'Roboto',
    'Lobster',
    'Montserrat',
    'Courier New',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _imageUrlController = TextEditingController(text: widget.currentImageUrl);
    _selectedImageUrl = widget.currentImageUrl;
    _selectedFont = widget.currentFont;

    _imageUrlController.addListener(() {
      setState(() {
        _selectedImageUrl = _imageUrlController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    if (_selectedImageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_selectedImageUrl),
        onBackgroundImageError: (_, __) {
          setState(() {
            _selectedImageUrl = '';
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildImagePreview(),
            const SizedBox(height: 20),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(fontFamily: _selectedFont),
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedFont,
              items: _fontOptions.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFont = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Font Style',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, {
                  'name': _nameController.text.trim(),
                  'imageUrl': _selectedImageUrl,
                  'font': _selectedFont,
                });
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
