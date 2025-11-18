import 'package:flutter/material.dart';


class TurnosDisponiblesScreen extends StatelessWidget {
  const TurnosDisponiblesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Turnos Disponibles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reserva un turno para entregar tu documentación en las oficinas de DUBSS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Calendario de turnos'),
                  ),
                );
              },
              icon: const Icon(Icons.event),
              label: const Text('Ver Disponibilidad'),
            ),
          ],
        ),
      ),
    );
  }
}