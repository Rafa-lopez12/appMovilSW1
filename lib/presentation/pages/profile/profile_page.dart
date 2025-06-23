// lib/presentation/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('No hay datos de usuario'),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveUtils.getHorizontalPadding(context)),
            child: Column(
              children: [
                // Header con avatar y nombre
                _buildProfileHeader(context, authProvider),
                
                const SizedBox(height: 32),
                
                // Información personal
                _buildInfoSection(context, user),
                
                const SizedBox(height: 24),
                
                // Opciones del menú
                _buildMenuSection(context, authProvider),
                
                const SizedBox(height: 32),
                
                // Botón de cerrar sesión
                _buildLogoutButton(context, authProvider),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                authProvider.userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Nombre
          Text(
            authProvider.userFullName ?? 'Usuario',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            authProvider.userEmail ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow(
            icon: IconlyLight.profile,
            label: 'Nombre',
            value: user.firstName,
          ),
          
          _buildInfoRow(
            icon: IconlyLight.profile,
            label: 'Apellido',
            value: user.lastName,
          ),
          
          _buildInfoRow(
            icon: IconlyLight.message,
            label: 'Email',
            value: user.email,
          ),
          
          if (user.phone != null)
            _buildInfoRow(
              icon: IconlyLight.call,
              label: 'Teléfono',
              value: user.phone!,
            ),
          
          if (user.address != null)
            _buildInfoRow(
              icon: IconlyLight.location,
              label: 'Dirección',
              value: user.address!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: IconlyLight.edit,
            title: 'Editar Perfil',
            onTap: () => _onEditProfile(context),
          ),
          
          _buildDivider(),
          
          _buildMenuItem(
            icon: IconlyLight.bag,
            title: 'Mis Pedidos',
            onTap: () => _onMyOrders(context),
          ),
          
          _buildDivider(),
          
          _buildMenuItem(
            icon: IconlyLight.heart,
            title: 'Favoritos',
            onTap: () => _onFavorites(context),
          ),
          
          _buildDivider(),
          
          _buildMenuItem(
            icon: IconlyLight.notification,
            title: 'Notificaciones',
            onTap: () => _onNotifications(context),
          ),
          
          _buildDivider(),
          
          _buildMenuItem(
            icon: IconlyLight.setting,
            title: 'Configuración',
            onTap: () => _onSettings(context),
          ),
          
          _buildDivider(),
          
          _buildMenuItem(
            icon: IconlyLight.info_circle,
            title: 'Ayuda y Soporte',
            onTap: () => _onHelp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                IconlyLight.arrow_right_2,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.divider,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : () => _onLogout(context, authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(IconlyLight.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Event handlers
  void _onEditProfile(BuildContext context) {
    // TODO: Navegar a página de edición de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onMyOrders(BuildContext context) {
    // TODO: Navegar a página de pedidos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onFavorites(BuildContext context) {
    // TODO: Navegar a página de favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onNotifications(BuildContext context) {
    // TODO: Navegar a configuración de notificaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onSettings(BuildContext context) {
    // TODO: Navegar a configuración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onHelp(BuildContext context) {
    // TODO: Navegar a ayuda y soporte
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función no implementada aún'),
      ),
    );
  }

  void _onLogout(BuildContext context, AuthProvider authProvider) async {
    // Mostrar diálogo de confirmación
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await authProvider.logout();
        
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}