
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/screens/zone_detail_page.dart';
import 'package:agrismart/screens/zone_form_page.dart';
import 'package:agrismart/widgets/fiche_exploitation.dart';
import 'package:agrismart/widgets/resume_exploitation.dart';
import 'package:agrismart/widgets/zone_card.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key});

  void _message(BuildContext context, String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texte)),
    );
  }

  // Ajouter une zone
  Future<void> _ajouter(BuildContext context) async {
    final noms = context.read<ZonesProvider>().noms();

    final nouvelle = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneFormPage(nomsExistants: noms),
      ),
    );

    if (nouvelle == null || !context.mounted) return;

    context.read<ZonesProvider>().ajouter(nouvelle);
    _message(context, 'Zone ajoutée');
  }

  // Ouvrir les détails d'une zone
  Future<void> _ouvrirDetail(BuildContext context, Zone zone) async {
    final noms = context.read<ZonesProvider>().noms(sauf: zone);

    final modifiee = await Navigator.push<Zone>(
      context,
      MaterialPageRoute(
        builder: (_) => ZoneDetailPage(
          zone: zone,
          nomsAutres: noms,
        ),
      ),
    );

    if (modifiee == null || !context.mounted) return;

    context.read<ZonesProvider>().remplacer(zone, modifiee);
    _message(context, 'Zone modifiée');
  }

  // Confirmer la suppression d'une zone
  Future<void> _confirmerSuppression(
      BuildContext context,
      Zone zone,
      ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la zone ?'),
        content: Text(
          'La zone ${zone.nom} sera supprimée définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;

    context.read<ZonesProvider>().supprimer(zone);
    _message(context, 'Zone supprimée');
  }

  // Construire une carte de zone
  Widget _carte(BuildContext context, Zone zone) {
    final provider = context.read<ZonesProvider>();

    return GestureDetector(
      onLongPress: () => _confirmerSuppression(context, zone),
      child: ZoneCard(
        zone: zone,
        onAugmenter: () => provider.modifierHumidite(zone, 5),
        onDiminuer: () => provider.modifierHumidite(zone, -5),
        onTap: () => _ouvrirDetail(context, zone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = context.watch<ZonesProvider>().zones;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AgriSmart'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouter(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          FicheExploitation(
            humiditeMoyenne: humiditeMoyenne(zones),
          ),
          ResumeExploitation(zones: zones),
          Expanded(
            child: zones.isEmpty
                ? const Center(
              child: Text('Aucune zone pour le moment'),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: zones.length,
              itemBuilder: (context, index) {
                return _carte(context, zones[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
