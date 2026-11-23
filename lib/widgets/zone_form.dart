import 'package:flutter/material.dart';
import 'package:agrismart/models/zone.dart';

class ZoneForm extends StatefulWidget {
  final Zone? zone;
  final void Function(Zone) onEnregistrer;
  final List<String> nomsExistants;

  const ZoneForm({super.key, this.zone, required this.onEnregistrer, this.nomsExistants = const []});

  @override
  State<ZoneForm> createState() => _ZoneFormState();
}

class _ZoneFormState extends State<ZoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _cultureCtrl = TextEditingController();
  final _humiditeCtrl = TextEditingController();
  final _seuilCtrl = TextEditingController();

  bool get _modeEdition => widget.zone != null;

  @override
  void initState() {
    super.initState();
    if (_modeEdition) {
      _nomCtrl.text = widget.zone!.nom;
      _cultureCtrl.text = widget.zone!.culture;
      _seuilCtrl.text = _formater(widget.zone!.seuil);
    }
  }

  String _formater(double n) => n % 1 == 0 ? n.toStringAsFixed(0) : n.toString();

  @override
  void dispose() {
    _nomCtrl.dispose();
    _cultureCtrl.dispose();
    _humiditeCtrl.dispose();
    _seuilCtrl.dispose();
    super.dispose();
  }

  double? _lireNombre(String? texte) {
    if (texte == null) return null;
    return double.tryParse(texte.trim().replaceAll(',', '.'));
  }

  String? _validatorTexte(String? valeur) {
    if (valeur == null || valeur.trim().length < 2) {
      return 'Ce champ est obligatoire (min 2 caractères)';
    }
    if (widget.nomsExistants.contains(valeur.trim())) {
      return 'Ce nom existe déjà';
    }
    return null;
  }

  String? _validatorPourcentage(String? valeur) {
    final nombre = _lireNombre(valeur);
    if (nombre == null) return 'Veuillez entrer un nombre valide';
    if (nombre < 0 || nombre > 100) return 'Le nombre doit être entre 0 et 100';
    return null;
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;

    final nom = _nomCtrl.text.trim();
    final culture = _cultureCtrl.text.trim();
    final seuil = _lireNombre(_seuilCtrl.text)!;

    double humidite;
    bool vanne;

    if (_modeEdition) {
      humidite = widget.zone!.humidite;
      vanne = widget.zone!.vanneOuverte;
    } else {
      humidite = _lireNombre(_humiditeCtrl.text) ?? 0.0;
      vanne = false;
    }

    final nouvelleZone = Zone(nom, culture, humidite, seuil, vanneOuverte: vanne);
    widget.onEnregistrer(nouvelleZone);
  }

  @override
  Widget build(BuildContext context) {
    // REGARDEZ ICI : Il n'y a plus le widget Text("Nouvelle zone") au début de la Column !
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom de la zone', border: OutlineInputBorder()),
              validator: _validatorTexte,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cultureCtrl,
              decoration: const InputDecoration(labelText: 'Culture', border: OutlineInputBorder()),
              validator: _validatorTexte,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!_modeEdition)
                  Expanded(
                    child: TextFormField(
                      controller: _humiditeCtrl,
                      decoration: const InputDecoration(labelText: 'Humidité (%)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _validatorPourcentage,
                    ),
                  ),
                if (!_modeEdition) const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _seuilCtrl,
                    decoration: const InputDecoration(labelText: 'Seuil (%)', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _validatorPourcentage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _soumettre,
              child: Text(_modeEdition ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}