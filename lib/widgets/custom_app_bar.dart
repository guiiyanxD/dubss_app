import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.userName,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      actions: actions ??
          [
            // Botón de notificaciones
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notificaciones');
                  },
                ),
                // Badge de notificaciones no leídas
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3', // TODO: Obtener de la API
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            // Menú de perfil
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _getInitials(userName ?? 'U'),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) => _handleMenuSelection(context, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: const [
                      Icon(Icons.person_outline),
                      SizedBox(width: 12),
                      Text('Mi Perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'notificaciones',
                  child: Row(
                    children: const [
                      Icon(Icons.notifications_outlined),
                      SizedBox(width: 12),
                      Text('Notificaciones'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'ayuda',
                  child: Row(
                    children: const [
                      Icon(Icons.help_outline),
                      SizedBox(width: 12),
                      Text('Ayuda'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'acerca',
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline),
                      SizedBox(width: 12),
                      Text('Acerca de'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  void _handleMenuSelection(BuildContext context, String value) async {
    switch (value) {
      case 'perfil':
        Navigator.pushNamed(context, '/perfil');
        break;

      case 'notificaciones':
        Navigator.pushNamed(context, '/notificaciones');
        break;

      case 'ayuda':
        _showHelpDialog(context);
        break;

      case 'acerca':
        _showAboutDialog(context);
        break;

      case 'logout':
        _handleLogout(context);
        break;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Necesitas ayuda?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Puedes contactarnos a través de:'),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text('soporte@dubss.edu.bo'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Teléfono'),
                subtitle: Text('+591 3 1234567'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('Horario de atención'),
                subtitle: Text('Lunes a Viernes\n8:00 AM - 6:00 PM'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DUBSS',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.school,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Sistema de Gestión de Becas Universitarias',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Dirección Universitaria de Bienestar Social y Salud',
        ),
        const SizedBox(height: 16),
        const Text(
          'Esta aplicación permite a los estudiantes gestionar sus solicitudes de becas de manera eficiente.',
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo

              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Cerrar sesión
              final authService = AuthService();
              await authService.logout();

              // Navegar a login
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}