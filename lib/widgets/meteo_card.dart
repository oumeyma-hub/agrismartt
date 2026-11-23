import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/models/meteo.dart';
import 'package:agrismart/providers/meteo_provider.dart';

class MeteoCard extends StatelessWidget {
  const MeteoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeteoProvider>();

    Widget contenu;

    if (provider.meteo != null) {
      // Afficher les dernières données disponibles,
      // même pendant une actualisation ou sans Internet.
      contenu = _Contenu(
        meteo: provider.meteo!,
        horsLigne: provider.horsLigne,
        derniereMiseAJour: provider.derniereMiseAJour,
        chargement: provider.etat == EtatMeteo.chargement,
        onReessayer: () {
          context.read<MeteoProvider>().charger();
        },
      );
    } else if (provider.etat == EtatMeteo.chargement) {
      contenu = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Chargement de la météo...'),
            ],
          ),
        ),
      );
    } else {
      contenu = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 8),
            Text(provider.erreur, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                context.read<MeteoProvider>().charger();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Card(margin: const EdgeInsets.all(16), child: contenu);
  }
}

// Contenu météo
class _Contenu extends StatelessWidget {
  final Meteo meteo;
  final bool horsLigne;
  final DateTime? derniereMiseAJour;
  final bool chargement;
  final VoidCallback onReessayer;

  const _Contenu({
    required this.meteo,
    required this.horsLigne,
    required this.derniereMiseAJour,
    required this.chargement,
    required this.onReessayer,
  });

  static const List<String> _jours = [
    'Lun',
    'Mar',
    'Mer',
    'Jeu',
    'Ven',
    'Sam',
    'Dim',
  ];

  String _formaterDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final heure = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year} à $heure:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;
    final pluie = meteo.pluieTotale;

    final conseil = pluie >= 5
        ? 'Pluie prévue (${pluie.toStringAsFixed(1)} mm) : '
              "repoussez l'irrigation"
        : 'Pas de pluie significative prévue';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et état de connexion
          Row(
            children: [
              Expanded(child: Text('Météo à Kébili', style: texte.titleMedium)),
              if (horsLigne)
                const Chip(
                  avatar: Icon(Icons.cloud_off, size: 16),
                  label: Text('Hors ligne'),
                )
              else
                const Chip(
                  avatar: Icon(Icons.cloud_done, size: 16),
                  label: Text('En ligne'),
                ),
            ],
          ),

          if (derniereMiseAJour != null) ...[
            const SizedBox(height: 4),
            Text(
              'Dernière mise à jour : '
              '${_formaterDate(derniereMiseAJour!)}',
              style: texte.bodySmall,
            ),
          ],

          if (chargement) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            const Text(
              'Actualisation de la météo...',
              style: TextStyle(fontSize: 12),
            ),
          ],

          const SizedBox(height: 12),

          // Température et informations météo
          Row(
            children: [
              Text(
                '${meteo.temperature.toStringAsFixed(0)} °C',
                style: texte.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Humidité de l'air : ${meteo.humiditeAir} %"),
                  Text('Vent : ${meteo.vent.toStringAsFixed(0)} km/h'),
                ],
              ),
            ],
          ),

          const Divider(height: 24),

          // Prévisions des jours disponibles
          for (final p in meteo.previsions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 48, child: Text(_jours[p.date.weekday - 1])),
                  Expanded(
                    child: Text(
                      '${p.tMin.toStringAsFixed(0)}° / '
                      '${p.tMax.toStringAsFixed(0)}°',
                    ),
                  ),
                  const Icon(Icons.water_drop_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('${p.pluie.toStringAsFixed(1)} mm'),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Conseil d'irrigation
          Text(conseil, style: const TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(height: 12),

          // Bouton d'actualisation
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: chargement ? null : onReessayer,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ),
        ],
      ),
    );
  }
}
