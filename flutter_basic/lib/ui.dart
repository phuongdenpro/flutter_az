import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Ui extends StatefulWidget {
  const Ui({Key? key}) : super(key: key);

  @override
  State<Ui> createState() {
    return _UiState();
  }
}

class _UiState extends State<Ui> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool liked = false;
  bool hide = true;
  String gender = 'Nam';
  DateTime? selectedDate;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  String get formattedDate {
    if (selectedDate == null) {
      return 'Chưa chọn ngày';
    }
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo UI')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Radio, Checkbox, DatePicker',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Nhập email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    obscureText: hide,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      suffixIcon: IconButton(
                        icon: Icon(
                          hide ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hide = !hide;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Tôi đồng ý'),
                    value: liked,
                    onChanged: (value) {
                      setState(() {
                        liked = value ?? false;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Nam'),
                    value: 'Nam',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value ?? 'Nam';
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Nữ'),
                    value: 'Nữ',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value ?? 'Nữ';
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Khác'),
                    value: 'Khác',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value ?? 'Khác';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Ngày sinh'),
                    subtitle: Text(formattedDate),
                    trailing: ElevatedButton(
                      onPressed: _showDatePicker,
                      child: const Text('Chọn ngày'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giới tính: $gender'),
                        Text(
                          'Trạng thái đồng ý: ${liked ? 'Đã đồng ý' : 'Chưa đồng ý'}',
                        ),
                        Text('Ngày sinh: $formattedDate'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScrollCameraGalleryDemo(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Demo Scroll + Camera + Gallery'),
            ),
          ),
        ],
      ),
    );
  }
}

class ScrollCameraGalleryDemo extends StatefulWidget {
  const ScrollCameraGalleryDemo({Key? key}) : super(key: key);

  @override
  State<ScrollCameraGalleryDemo> createState() =>
      _ScrollCameraGalleryDemoState();
}

class _ScrollCameraGalleryDemoState extends State<ScrollCameraGalleryDemo> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? imageData;
  String? imageSourceLabel;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        imageData = bytes;
        imageSourceLabel = source == ImageSource.camera ? 'Camera' : 'Gallery';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scroll + Camera + Gallery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Scroll View Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[(index + 1) * 100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Box ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chụp ảnh hoặc lấy ảnh từ gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (imageData != null) ...[
              Text(
                'Ảnh chọn từ: $imageSourceLabel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(imageData!, fit: BoxFit.cover),
              ),
            ] else ...[
              const Text(
                'Chưa có ảnh nào. Nhấn Camera hoặc Gallery để chọn ảnh.',
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Danh sách dài để cuộn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(
                20,
                (index) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[400],
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Mục ${index + 1}'),
                    subtitle: Text('Nội dung cuộn demo cho item ${index + 1}.'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
