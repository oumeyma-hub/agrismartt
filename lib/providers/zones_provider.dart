import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/data/jeu_de_donnees.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/auth_provider.dart';

class ZonesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthProvider _auth;

  final List<Zone> _zones = [];

  String? _uidActuel;
  bool _chargementTermine = false;

  Future<void> _fileSauvegarde = Future<void>.value();

  ZonesProvider(this._prefs, this._auth) {
    _auth.addListener(_surChangementUtilisateur);

    if (_auth.initialise) {
      _surChangementUtilisateur();
    }
  }

  String _cleZones(String uid) => 'zones_$uid';

  // Getters
  List<Zone> get zones => List.unmodifiable(_zones);

  int get nombre => _zones.length;

  int get nombreAIrriguer =>
      _zones.where((zone) => zone.besoinIrrigation).length;

  bool get chargementTermine => _chargementTermine;

  // Noms des zones
  List<String> noms({Zone? sauf}) {
    return _zones
        .where((zone) => zone != sauf)
        .map((zone) => zone.nom)
        .toList();
  }

  // Détecter les changements d'utilisateur
  void _surChangementUtilisateur() {
    if (!_auth.initialise) return;

    final utilisateur = _auth.utilisateur;
    final nouveauUid = utilisateur?.uid;

    if (nouveauUid == _uidActuel) return;

    _uidActuel = nouveauUid;

    _zones.clear();
    _chargementTermine = false;

    if (nouveauUid == null) {
      _chargementTermine = true;
      notifyListeners();
      return;
    }

    unawaited(_chargerZones(nouveauUid));

    notifyListeners();
  }

  // Charger les zones de l'utilisateur connecté
  Future<void> _chargerZones(String uid) async {
    try {
      final texte = _prefs.getString(_cleZones(uid));

      if (texte != null) {
        final donnees = jsonDecode(texte) as List<dynamic>;

        final zonesChargees = donnees.map((element) {
          return Zone.fromJson(Map<String, dynamic>.from(element as Map));
        }).toList();

        if (_uidActuel != uid) return;

        _zones
          ..clear()
          ..addAll(zonesChargees);
      } else {
        if (_uidActuel != uid) return;

        _zones
          ..clear()
          ..addAll(jeuDeDonnees());

        await _sauvegarderZones(uid);
      }
    } catch (e) {
      debugPrint('Erreur de chargement des zones : $e');

      if (_uidActuel != uid) return;

      _zones
        ..clear()
        ..addAll(jeuDeDonnees());

      await _sauvegarderZones(uid);
    }

    if (_uidActuel != uid) return;

    _chargementTermine = true;
    notifyListeners();
  }

  // Sauvegarder les zones d'un utilisateur
  Future<void> _sauvegarderZones(String uid) async {
    final donnees = _zones.map((zone) => zone.toJson()).toList();

    await _prefs.setString(_cleZones(uid), jsonEncode(donnees));
  }

  // Sauvegarder les modifications
  void _sauvegarder() {
    final uid = _uidActuel;

    if (uid == null || !_chargementTermine) return;

    final donnees = _zones.map((zone) => zone.toJson()).toList();
    final texte = jsonEncode(donnees);

    _fileSauvegarde = _fileSauvegarde.then((_) async {
      try {
        await _prefs.setString(_cleZones(uid), texte);
      } catch (e) {
        debugPrint('Erreur de sauvegarde des zones : $e');
      }
    });
  }

  // Modifier l'humidité
  void modifierHumidite(Zone zone, double delta) {
    zone.humidite = (zone.humidite + delta).clamp(0, 100).toDouble();

    _sauvegarder();
    notifyListeners();
  }

  // Ajouter une zone
  void ajouter(Zone zone) {
    _zones.add(zone);

    _sauvegarder();
    notifyListeners();
  }

  // Remplacer une zone
  void remplacer(Zone ancienne, Zone nouvelle) {
    final index = _zones.indexOf(ancienne);

    if (index == -1) return;

    _zones[index] = nouvelle;

    _sauvegarder();
    notifyListeners();
  }

  // Supprimer une zone
  void supprimer(Zone zone) {
    _zones.remove(zone);

    _sauvegarder();
    notifyListeners();
  }

  // Réinitialiser les zones de l'utilisateur connecté
  Future<void> reinitialiserZones() async {
    final uid = _uidActuel;

    if (uid == null || !_chargementTermine) return;

    try {
      // Attendre les sauvegardes précédentes
      await _fileSauvegarde;

      // Vérifier que le compte n'a pas changé
      if (_uidActuel != uid) return;

      // Restaurer les données initiales
      _zones
        ..clear()
        ..addAll(jeuDeDonnees());

      // Enregistrer les zones réinitialisées
      await _sauvegarderZones(uid);

      if (_uidActuel != uid) return;

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur de réinitialisation des zones : $e');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_surChangementUtilisateur);
    super.dispose();
  }
}
