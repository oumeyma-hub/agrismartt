import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/screens/zone_form_page.dart'; // L'import qui manquait
import 'package:agrismart/theme/app_theme.dart';

class ZoneDetailPage extends StatelessWidget {
  final Zone zone;
  final List<String> nomsAutres;

  const ZoneDetailPage({super.key, required this.zone, this.nomsAutres = const []});

  Future<void> _modifier(BuildContext context) async {
    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(zone: zone, nomsExistants: nomsAutres),
      ),
    );
    if (modifiee != null && context.mounted) {
      Navigator.pop(context, modifiee);
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = zone.besoinIrrigation ? AppTheme.echec : AppTheme.succes;
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(zone.nom)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: couleur..withValues(alpha: 0.5),
                child: Text(
                  zone.culture.substring(0, zone.culture.length > 4 ? 4 : zone.culture.length).toUpperCase(),
                  style: TextStyle(color: couleur, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.nom, style: texte.headlineSmall),
                    Text(zone.culture, style: texte.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${zone.humidite.toStringAsFixed(0)} %',
              style: texte.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: couleur),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: zone.humidite / 100,
            color: couleur,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              diagnostic(zone),
              style: TextStyle(color: couleur, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.water_drop), title: const Text('Humidité actuelle'), trailing: Text('${zone.humidite} %')),
                ListTile(leading: const Icon(Icons.flag), title: const Text('Seuil d\'irrigation'), trailing: Text('${zone.seuil} %')),
                ListTile(
                  leading: Icon(zone.vanneOuverte ? Icons.toggle_on : Icons.toggle_off),
                  title: const Text('Vanne'),
                  trailing: Text(zone.vanneOuverte ? 'Ouverte' : 'Fermée'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _modifier(context),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier cette zone'),
          ),
        ],
      ),
    );
  }
}