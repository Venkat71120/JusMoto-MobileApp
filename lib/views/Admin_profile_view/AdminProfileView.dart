import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/auth_services/AdminLoginService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Profile'),
      ),
      body: Consumer<AdminLoginService>(
        builder: (context, adminService, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar Section
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: adminService.image != null
                      ? NetworkImage(adminService.image!)
                      : null,
                  child: adminService.image == null
                      ? Text(
                          (adminService.name.isNotEmpty
                              ? adminService.name[0].toUpperCase()
                              : 'A'),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  adminService.name.isNotEmpty ? adminService.name : 'Admin',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  adminService.email,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    adminService.role.isNotEmpty ? adminService.role : 'Admin',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),

              // Info Section
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Username'),
                subtitle: Text(adminService.username),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('User ID'),
                subtitle: Text(adminService.userId),
              ),

              const Divider(),
              const SizedBox(height: 8),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(LocalKeys.confirmLogout),
                      content: Text(LocalKeys.logoutConfirmationMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(LocalKeys.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(LocalKeys.signOut),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await adminService.clearAdminData();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(LocalKeys.signOut),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
