import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/models/user_model.dart';
import '../../profile/services/profile_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileService _profileService;
  late Future<UserModel> _futureUser;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(ApiClient(TokenStorage()));
    _futureUser = _profileService.getMe();
  }

  Future<void> _refreshUser() async {
    setState(() {
      _futureUser = _profileService.getMe();
    });
  }

  Future<void> _logout() async {
    await TokenStorage().clearToken();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget(message: 'Đang tải thông tin...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(message: snapshot.error.toString(), onRetry: _refreshUser);
          }

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Thông tin người dùng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Text('Họ và tên: ${user.fullName}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Role: ${user.role}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('ID: ${user.id}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/profile/edit'),
                  child: const Text('Cập nhật thông tin'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/profile/change-password'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
                  child: const Text('Đổi mật khẩu'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
