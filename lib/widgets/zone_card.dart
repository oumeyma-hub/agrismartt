
import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/theme/app_theme.dart';

class ZoneCard extends StatelessWidget {
  final Zone zone;
  final VoidCallback onAugmenter;
  final VoidCallback onDiminuer;
  final VoidCallback? onTap;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onAugmenter,
    required this.onDiminuer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Couleur selon le besoin d'irrigation
    final couleurStatut =
    zone.besoinIrrigation ? AppTheme.echec : AppTheme.succes;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cercle avec les initiales de la culture
              CircleAvatar(
                radius: 24,
                backgroundColor: couleurStatut.withValues(alpha: 0.2),
                child: Text(
                  zone.culture
                      .substring(
                    0,
                    zone.culture.length > 4
                        ? 4
                        : zone.culture.length,
                  )
                      .toUpperCase(),
                  style: TextStyle(
                    color: couleurStatut,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Informations de la zone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      diagnostic(zone),
                      style: TextStyle(
                        color: couleurStatut,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Humidité et boutons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${zone.humidite.toStringAsFixed(0)} %',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: onDiminuer,
                        color: AppTheme.echec,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: onAugmenter,
                        color: AppTheme.succes,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
