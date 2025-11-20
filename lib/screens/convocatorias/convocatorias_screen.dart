import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/convocatoria_provider.dart';
import '../../models/convocatoria.dart';
import '../../utils/constants.dart';
import '../../utils/app_helpers.dart';

class ConvocatoriasScreen extends StatefulWidget {
  const ConvocatoriasScreen({Key? key}) : super(key: key);

  @override
  State<ConvocatoriasScreen> createState() => _ConvocatoriasScreenState();
}

class _ConvocatoriasScreenState extends State<ConvocatoriasScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConvocatoriaProvider>().cargarConvocatorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConvocatoriaProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.cargarConvocatorias(),
          child: Column(
            children: [
              _buildFiltros(provider),
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltros(ConvocatoriaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: provider.filtroTipoBeca,
              decoration: const InputDecoration(
                labelText: 'Tipo de Beca',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(value: 'socioeconomica', child: Text('Socioeconómica')),
                DropdownMenuItem(value: 'academica', child: Text('Académica')),
                DropdownMenuItem(value: 'extension', child: Text('Extensión')),
              ],
              onChanged: (value) => provider.setFiltroTipoBeca(value),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Solo Activas'),
            selected: provider.soloActivas,
            onSelected: (value) => provider.setSoloActivas(value),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ConvocatoriaProvider provider) {
    if (provider.isLoading && provider.convocatorias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.cargarConvocatorias(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.convocatorias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay convocatorias disponibles',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.convocatorias.length,
      itemBuilder: (context, index) {
        final convocatoria = provider.convocatorias[index];
        return _buildConvocatoriaCard(convocatoria);
      },
    );
  }

  Widget _buildConvocatoriaCard(Convocatoria convocatoria) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _mostrarDetalle(convocatoria),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      convocatoria.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildEstadoChip(convocatoria),
                ],
              ),

              const SizedBox(height: 8),

              // Código
              Text(
                convocatoria.codigo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),

              // Tipo de beca
              Row(
                children: [
                  Icon(
                    AppHelpers.getTipoBecaIcon(convocatoria.tipoBeca),
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppHelpers.getTipoBecaNombre(convocatoria.tipoBeca),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${convocatoria.subtipo}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Fechas
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Hasta: ${dateFormat.format(convocatoria.fechaFin)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  if (convocatoria.estaVigente) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${convocatoria.diasRestantes} días',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(Convocatoria convocatoria) {
    Color color;
    IconData icon;

    if (convocatoria.estaVigente) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (convocatoria.proximamente) {
      color = Colors.blue;
      icon = Icons.schedule;
    } else {
      color = Colors.grey;
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            convocatoria.estado,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(Convocatoria convocatoria) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      convocatoria.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildEstadoChip(convocatoria),

              const SizedBox(height: 24),

              // Información
              _buildInfoRow(Icons.confirmation_number, 'Código', convocatoria.codigo),
              _buildInfoRow(
                AppHelpers.getTipoBecaIcon(convocatoria.tipoBeca),
                'Tipo de Beca',
                AppHelpers.getTipoBecaNombre(convocatoria.tipoBeca),
              ),
              _buildInfoRow(Icons.category, 'Subtipo', convocatoria.subtipo),
              _buildInfoRow(
                Icons.calendar_today,
                'Fecha Inicio',
                dateFormat.format(convocatoria.fechaInicio),
              ),
              _buildInfoRow(
                Icons.event,
                'Fecha Fin',
                dateFormat.format(convocatoria.fechaFin),
              ),
              _buildInfoRow(
                Icons.gavel,
                'Límite Apelación',
                dateFormat.format(convocatoria.fechaLimiteApelacion),
              ),

              if (convocatoria.descripcion != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  convocatoria.descripcion!,
                  style: TextStyle(color: Colors.grey[700], height: 1.5),
                ),
              ],

              const SizedBox(height: 32),

              // Botón de acción
              if (convocatoria.estaVigente)
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navegar a crear trámite
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad de solicitud próximamente'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text(
                      'Solicitar Beca',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
}