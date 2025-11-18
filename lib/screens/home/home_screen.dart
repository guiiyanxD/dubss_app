// screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../convocatorias/convocatorias_screen.dart';
import '../tramites/mis_tramites_screen.dart';
import '../turnos/turnos_disponibles_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userName = '';

  final StorageService _storageService = StorageService();

  // Lista de pantallas para la navegación
  final List<Widget> _screens = [
    const DashboardTab(),
    const ConvocatoriasScreen(),
    const MisTramitesScreen(),
    const TurnosDisponiblesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _storageService.getUserName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        userName: _userName,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Convocatorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Mis Trámites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Turnos',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'DUBSS';
      case 1:
        return 'Convocatorias';
      case 2:
        return 'Mis Trámites';
      case 3:
        return 'Turnos';
      default:
        return 'DUBSS';
    }
  }
}

// ============================================
// DASHBOARD TAB (Inicio)
// ============================================

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final StorageService _storageService = StorageService();
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _storageService.getUserName();
    final email = await _storageService.getUserEmail();

    if (mounted) {
      setState(() {
        _userName = name ?? 'Usuario';
        _userEmail = email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo personalizado
            _buildWelcomeCard(),

            const SizedBox(height: 24),

            // Accesos rápidos
            Text(
              'Accesos Rápidos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildQuickAccessGrid(),

            const SizedBox(height: 24),

            // Notificaciones recientes
            Text(
              'Actividad Reciente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días';

    if (hour >= 12 && hour < 18) {
      greeting = 'Buenas tardes';
    } else if (hour >= 18) {
      greeting = 'Buenas noches';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.waving_hand,
                color: Colors.amber[300],
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final quickAccess = [
      {
        'icon': Icons.campaign,
        'label': 'Ver Convocatorias',
        'color': Colors.blue,
        'route': '/convocatorias',
      },
      {
        'icon': Icons.add_box,
        'label': 'Nueva Solicitud',
        'color': Colors.green,
        'route': '/crear-tramite',
      },
      {
        'icon': Icons.calendar_month,
        'label': 'Reservar Turno',
        'color': Colors.orange,
        'route': '/reservar-turno',
      },
      {
        'icon': Icons.folder_open,
        'label': 'Mis Trámites',
        'color': Colors.purple,
        'route': '/mis-tramites',
      },
      {
        'icon': Icons.notifications,
        'label': 'Notificaciones',
        'color': Colors.red,
        'route': '/notificaciones',
      },
      {
        'icon': Icons.person,
        'label': 'Mi Perfil',
        'color': Colors.teal,
        'route': '/perfil',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: quickAccess.length,
      itemBuilder: (context, index) {
        final item = quickAccess[index];
        return _buildQuickAccessCard(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          color: item['color'] as Color,
          onTap: () {
            // TODO: Implementar navegación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navegando a: ${item['label']}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // TODO: Obtener actividad real desde la API
    final activities = [
      {
        'icon': Icons.check_circle,
        'title': 'Documento aprobado',
        'subtitle': 'Certificado de estudios - Hace 2 horas',
        'color': Colors.green,
      },
      {
        'icon': Icons.schedule,
        'title': 'Turno reservado',
        'subtitle': 'Mañana 10:00 AM - Hace 1 día',
        'color': Colors.orange,
      },
      {
        'icon': Icons.info,
        'title': 'Nueva convocatoria',
        'subtitle': 'Beca Socioeconómica 2025 - Hace 3 días',
        'color': Colors.blue,
      },
    ];

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividad reciente',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'] as IconData,
                  color: activity['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['subtitle'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        );
      },
    );
  }
}