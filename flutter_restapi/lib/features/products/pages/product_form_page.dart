import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_widget.dart';

class ProductFormPage extends StatefulWidget {
  final int? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  late final ProductService _productService;
  late Future<ProductModel?> _futureProduct;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiClient(TokenStorage()));
    if (widget.productId != null) {
      _futureProduct = _productService.getProductById(widget.productId!).then((value) {
        _nameController.text = value.name;
        _descriptionController.text = value.description;
        _priceController.text = value.price.toString();
        return value;
      });
    } else {
      _futureProduct = Future.value(null);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = int.tryParse(_priceController.text.trim()) ?? 0;
      ProductModel product;

      if (widget.productId != null) {
        product = await _productService.updateProduct(
          id: widget.productId!,
          name: name,
          description: description,
          price: price,
        );
      } else {
        product = await _productService.createProduct(
          name: name,
          description: description,
          price: price,
        );
      }

      if (_selectedImage != null) {
        await _productService.uploadProductImage(productId: product.id, image: _selectedImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.productId != null ? 'Cập nhật sản phẩm thành công' : 'Tạo sản phẩm thành công')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/manage');
        }
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.productId != null ? 'Sửa sản phẩm' : 'Tạo sản phẩm';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/manage');
            }
          },
        ),
      ),
      body: FutureBuilder<ProductModel?>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget(message: 'Đang tải dữ liệu...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _futureProduct = _productService.getProductById(widget.productId!);
                });
              },
            );
          }

          final existingImageUrl = snapshot.data?.imageUrl;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity))
                          : existingImageUrl != null && existingImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    existingImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.photo_library, size: 48, color: Colors.indigo),
                                    ),
                                  ),
                                )
                              : const Center(child: Icon(Icons.photo_library, size: 48, color: Colors.indigo)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Chạm để chọn ảnh sản phẩm', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Tên sản phẩm',
                          hintText: 'Nhập tên sản phẩm',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tên sản phẩm không được để trống';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Mô tả',
                          hintText: 'Nhập mô tả sản phẩm',
                          controller: _descriptionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mô tả không được để trống';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Giá',
                          hintText: 'Nhập giá sản phẩm',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Giá không được để trống';
                            }
                            final price = int.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'Giá không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                        ],
                        CustomButton(
                          label: widget.productId != null ? 'Cập nhật' : 'Tạo sản phẩm',
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
