
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';

import 'package:agrismart/theme/app_theme.dart';

import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/meteo_card.dart';

class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération des zones
    final zones = context.watch<ZonesProvider>().zones;

    // Tri des zones selon leur humidité
    final tri = [...zones]
      ..sort((a, b) => a.humidite.compareTo(b.humidite));

    // Calcul des zones nécessitant une irrigation
    final aIrriguer =
        zones.where((z) => z.besoinIrrigation).length;

    final pourcentage = zones.isEmpty
        ? 0
        : (aIrriguer * 100 / zones.length).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Statistiques'),
      ),

      body: RefreshIndicator(
        onRefresh: () =>
            context.read<MeteoProvider>().charger(),

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [

            // Carte météo
            const MeteoCard(),

            // Affichage des statistiques agricoles
            if (zones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Aucune donnée à afficher',
                  ),
                ),
              )
            else ...[

              // Résumé de l'exploitation
              ResumeExploitation(zones: zones),

              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      '$aIrriguer zone(s) sur '
                          '${zones.length} à irriguer '
                          '($pourcentage %)',

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Humidité par zone',
                      style: Theme.of(context)
                          .textTheme.titleMedium,
                    ),

                    const SizedBox(height: 8),

                    for (final z in tri)
                      ListTile(
                        title: Text(z.nom),

                        subtitle: LinearProgressIndicator(
                          value: z.humidite / 100,

                          color: z.besoinIrrigation
                              ? AppTheme.echec
                              : AppTheme.succes,
                        ),

                        trailing: Text(
                          '${z.humidite.toStringAsFixed(0)} %',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
