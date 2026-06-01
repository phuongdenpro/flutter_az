import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_restapi/app/router/route_paths.dart';
import 'package:flutter_restapi/core/di/app_dependencies.dart';
import 'package:flutter_restapi/core/theme/app_colors.dart';
import 'package:flutter_restapi/features/auth/data/models/user_model.dart';
import 'package:flutter_restapi/core/notifiers/profile_refresh_notifier.dart';
import 'package:flutter_restapi/features/profile/data/services/profile_service.dart';
import 'package:flutter_restapi/shared/widgets/custom_button.dart';
import 'package:flutter_restapi/shared/widgets/error_widget.dart';
import 'package:flutter_restapi/shared/widgets/loading_widget.dart';

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
    _profileService = ProfileService(AppDependencies.instance.apiClient);
    _futureUser = _profileService.getMe();
    ProfileRefreshNotifier.instance.tick.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    ProfileRefreshNotifier.instance.tick.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    setState(() => _futureUser = _profileService.getMe());
    await _futureUser;
  }

  Future<void> _openEditProfile() async {
    final updated = await context.push<bool>(RoutePaths.profileEdit);
    if (updated == true && mounted) {
      await _refreshUser();
    }
  }

  Future<void> _logout() async {
    await AppDependencies.instance.tokenStorage.clearToken();
    if (mounted) context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingWidget(message: 'Đang tải thông tin...');
            }
            if (snapshot.hasError) {
              return AppErrorWidget(message: snapshot.error.toString(), onRetry: _refreshUser);
            }

            final user = snapshot.data!;
            final isAdmin = user.role.toLowerCase() == 'admin';

            return RefreshIndicator(
              onRefresh: _refreshUser,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Tài khoản', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initials(user.fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileMenuTile(
                    icon: Icons.edit_outlined,
                    title: 'Cập nhật thông tin',
                    onTap: _openEditProfile,
                  ),
                  _ProfileMenuTile(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () => context.push(RoutePaths.changePassword),
                  ),
                  if (isAdmin)
                    _ProfileMenuTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Quản lý sản phẩm',
                      onTap: () => context.push(RoutePaths.manage),
                    ),
                  const SizedBox(height: 24),
                  CustomButton(label: 'Đăng xuất', color: AppColors.error, onPressed: _logout),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
