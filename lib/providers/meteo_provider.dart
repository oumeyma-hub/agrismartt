import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/models/meteo.dart';
import 'package:agrismart/services/meteo_service.dart';

enum EtatMeteo { chargement, succes, erreur }

class MeteoProvider extends ChangeNotifier {
  final MeteoService _service;
  final SharedPreferences _prefs;

  static const String _cleMeteo = 'meteo_cache';
  static const String _cleDate = 'meteo_cache_date';

  MeteoProvider({required SharedPreferences prefs, MeteoService? service})
    : _prefs = prefs,
      _service = service ?? MeteoService();

  EtatMeteo _etat = EtatMeteo.chargement;

  Meteo? _meteo;
  String _erreur = '';
  DateTime? _derniereMiseAJour;
  bool _horsLigne = false;

  EtatMeteo get etat => _etat;
  Meteo? get meteo => _meteo;
  String get erreur => _erreur;
  DateTime? get derniereMiseAJour => _derniereMiseAJour;
  bool get horsLigne => _horsLigne;

  Future<void> charger() async {
    _etat = EtatMeteo.chargement;
    _erreur = '';
    notifyListeners();

    try {
      // 1. Récupérer la météo depuis Internet
      final meteoRecue = await _service.charger();

      // 2. Enregistrer les données dans le cache local
      final dateActuelle = DateTime.now();

      await _prefs.setString(_cleMeteo, jsonEncode(meteoRecue.toJson()));

      await _prefs.setString(_cleDate, dateActuelle.toIso8601String());

      // 3. Mettre à jour les données affichées
      _meteo = meteoRecue;
      _derniereMiseAJour = dateActuelle;
      _horsLigne = false;
      _erreur = '';
      _etat = EtatMeteo.succes;
    } catch (e) {
      // Internet indisponible : essayer de charger le cache
      debugPrint('Erreur météo Internet : $e');

      final cacheDisponible = await _chargerDepuisCache();

      if (cacheDisponible) {
        _horsLigne = true;
        _erreur = '';
        _etat = EtatMeteo.succes;
      } else {
        _horsLigne = true;
        _meteo = null;
        _derniereMiseAJour = null;
        _erreur =
            'Pas de connexion Internet et aucune donnée météo enregistrée.';
        _etat = EtatMeteo.erreur;
      }
    }

    notifyListeners();
  }

  // Récupérer les dernières données météo enregistrées
  Future<bool> _chargerDepuisCache() async {
    try {
      final donneesJson = _prefs.getString(_cleMeteo);
      final dateJson = _prefs.getString(_cleDate);

      if (donneesJson == null || dateJson == null) {
        return false;
      }

      final donnees = jsonDecode(donneesJson);

      if (donnees is! Map) {
        return false;
      }

      final mapMeteo = Map<String, dynamic>.from(donnees);

      _meteo = Meteo.fromJson(mapMeteo);
      _derniereMiseAJour = DateTime.parse(dateJson);

      debugPrint('Météo chargée depuis le cache local.');

      return true;
    } catch (e) {
      debugPrint('Erreur de lecture du cache météo : $e');
      return false;
    }
  }
}
