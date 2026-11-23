import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Confirmation de déconnexion
  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );

    if (confirmation == true && context.mounted) {
      await context.read<AuthProvider>().deconnexion();
    }
  }

  // Confirmation de réinitialisation des zones
  Future<void> _confirmerReinitialisation(BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réinitialiser les zones'),
          content: const Text(
            'Voulez-vous restaurer les zones initiales ? '
            'Vos modifications seront perdues.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    if (confirmation == true && context.mounted) {
      await context.read<ZonesProvider>().reinitialiserZones();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les zones ont été réinitialisées.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreZones = context.select<ZonesProvider, int>(
      (provider) => provider.nombre,
    );

    final utilisateur = context.watch<AuthProvider>().utilisateur;

    final reglages = context.watch<ReglagesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.agriculture, size: 40),
            ),
          ),

          const SizedBox(height: 12),

          const Center(
            child: Text(
              'Exploitation AgriSmart',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const Center(child: Text('Kébili, Tunisie')),

          const SizedBox(height: 16),
          const Divider(),

          // Informations utilisateur
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Adresse email'),
            subtitle: Text(utilisateur?.email ?? 'Aucun utilisateur connecté'),
          ),

          const Divider(),

          // Nombre de zones
          ListTile(
            leading: const Icon(Icons.grass),
            title: const Text('Zones suivies'),
            trailing: Text(
              '$nombreZones',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const Divider(),

          // Apparence
          const SizedBox(height: 12),

          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text(
              'Apparence',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Choisissez le thème de l’application'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<ThemeMode>(
              initialValue: reglages.themeMode,
              decoration: const InputDecoration(
                labelText: 'Thème',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('Système'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  reglages.changerTheme(mode);
                }
              },
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Réinitialisation des zones
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => _confirmerReinitialisation(context),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Réinitialiser les zones'),
          ),

          const SizedBox(height: 20),

          // Déconnexion
          FilledButton.icon(
            onPressed: () => _confirmerDeconnexion(context),
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
