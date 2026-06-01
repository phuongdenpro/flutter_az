import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_restapi/app/router/route_paths.dart';
import 'package:flutter_restapi/core/di/app_dependencies.dart';
import 'package:flutter_restapi/features/auth/data/models/user_model.dart';
import 'package:flutter_restapi/core/notifiers/profile_refresh_notifier.dart';
import 'package:flutter_restapi/features/profile/data/services/profile_service.dart';
import 'package:flutter_restapi/shared/widgets/custom_button.dart';
import 'package:flutter_restapi/shared/widgets/custom_text_field.dart';
import 'package:flutter_restapi/shared/widgets/error_widget.dart';
import 'package:flutter_restapi/shared/widgets/loading_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late final ProfileService _profileService;
  late Future<UserModel> _futureUser;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(AppDependencies.instance.apiClient);
    _futureUser = _profileService.getMe().then((UserModel user) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      return user;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await _profileService.updateProfile(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ProfileRefreshNotifier.instance.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
        context.pop(true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật hồ sơ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RoutePaths.account);
            }
          },
        ),
      ),
      body: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget(message: 'Đang tải hồ sơ...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(message: snapshot.error.toString(), onRetry: () {
              setState(() {
                _futureUser = _profileService.getMe();
              });
            });
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Họ và tên',
                          hintText: 'Nhập họ tên',
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Họ tên không được để trống';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          hintText: 'Nhập email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email không được để trống';
                            }
                            if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 12),
                        ],
                        CustomButton(label: 'Lưu lại', isLoading: _isLoading, onPressed: _saveProfile),
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
