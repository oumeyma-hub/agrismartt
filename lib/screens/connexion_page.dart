
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/screens/inscription_page.dart';

String? validerEmail(String? valeur) {
  final email = (valeur ?? '').trim();

  if (email.isEmpty) {
    return "L'email est obligatoire";
  }

  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Email invalide';
  }

  return null;
}

String? validerMotDePasse(String? valeur) {
  if (valeur == null || valeur.isEmpty) {
    return 'Le mot de passe est obligatoire';
  }

  if (valeur.length < 6) {
    return '6 caractères minimum';
  }

  return null;
}

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _mdpCtrl = TextEditingController();

  static const String _cleEmail = 'email_sauvegarde';

  bool _masquer = true;
  bool _seSouvenir = false;
  bool _chargementEmail = true;

  @override
  void initState() {
    super.initState();
    _chargerEmail();
  }

  // Charger l'email sauvegardé
  Future<void> _chargerEmail() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString(_cleEmail);

    if (!mounted) return;

    setState(() {
      if (email != null && email.isNotEmpty) {
        _emailCtrl.text = email;
        _seSouvenir = true;
      }

      _chargementEmail = false;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mdpCtrl.dispose();
    super.dispose();
  }

  // Connexion
  Future<void> _connecter() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final ok = await auth.connexion(
      _emailCtrl.text.trim(),
      _mdpCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      final prefs = await SharedPreferences.getInstance();

      if (_seSouvenir) {
        await prefs.setString(
          _cleEmail,
          _emailCtrl.text.trim(),
        );
      } else {
        await prefs.remove(_cleEmail);
      }
    }
  }

  // Réinitialisation du mot de passe
  Future<void> _motDePasseOublie() async {
    if (validerEmail(_emailCtrl.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Saisissez d'abord votre email"),
        ),
      );
      return;
    }

    final ok = await context
        .read<AuthProvider>()
        .reinitialiserMotDePasse(_emailCtrl.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Email de réinitialisation envoyé'
              : 'Impossible de réinitialiser le mot de passe',
        ),
      ),
    );
  }

  // Ouvrir la page d'inscription
  void _ouvrirInscription() {
    context.read<AuthProvider>().effacerErreur();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InscriptionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.agriculture,
                      size: 64,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'AgriSmart',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 24),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: validerEmail,
                    ),

                    const SizedBox(height: 8),

                    // Mémoriser l'email
                    if (!_chargementEmail)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Se souvenir de mon email'),
                        value: _seSouvenir,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (valeur) {
                          setState(() {
                            _seSouvenir = valeur ?? false;
                          });
                        },
                      ),

                    const SizedBox(height: 8),

                    // Mot de passe
                    TextFormField(
                      controller: _mdpCtrl,
                      obscureText: _masquer,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _masquer
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _masquer = !_masquer;
                            });
                          },
                        ),
                      ),
                      validator: validerMotDePasse,
                    ),

                    // Message d'erreur
                    if (auth.erreur != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.erreur!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Bouton de connexion
                    FilledButton(
                      onPressed: auth.occupe ? null : _connecter,
                      child: auth.occupe
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Se connecter'),
                    ),

                    // Mot de passe oublié
                    TextButton(
                      onPressed:
                      auth.occupe ? null : _motDePasseOublie,
                      child: const Text('Mot de passe oublié ?'),
                    ),

                    // Inscription
                    TextButton(
                      onPressed:
                      auth.occupe ? null : _ouvrirInscription,
                      child: const Text("Pas de compte ? S'inscrire"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
