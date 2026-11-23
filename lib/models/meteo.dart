
class PrevisionJour {
  final DateTime date;
  final double tMax;
  final double tMin;
  final double pluie;

  const PrevisionJour({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.pluie,
  });
}

class Meteo {
  final double temperature;
  final int humiditeAir;
  final double vent;
  final List<PrevisionJour> previsions;

  const Meteo({
    required this.temperature,
    required this.humiditeAir,
    required this.vent,
    required this.previsions,
  });

  // Calcul de la pluie totale prévue
  double get pluieTotale =>
      previsions.fold(0.0, (somme, p) => somme + p.pluie);

  // Conversion de l'objet Meteo vers JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humiditeAir': humiditeAir,
      'vent': vent,
      'previsions': previsions.map((p) {
        return {
          'date': p.date.toIso8601String(),
          'tMax': p.tMax,
          'tMin': p.tMin,
          'pluie': p.pluie,
        };
      }).toList(),
    };
  }

  // Conversion JSON vers objet Dart
  factory Meteo.fromJson(Map<String, dynamic> json) {
    // Vérifier si le JSON vient de l'API ou du cache local
    if (json.containsKey('temperature')) {
      final liste = json['previsions'] as List<dynamic>;

      return Meteo(
        temperature: (json['temperature'] as num).toDouble(),
        humiditeAir: (json['humiditeAir'] as num).toInt(),
        vent: (json['vent'] as num).toDouble(),
        previsions: liste.map((element) {
          final p = Map<String, dynamic>.from(element as Map);
          return PrevisionJour(
            date: DateTime.parse(p['date'] as String),
            tMax: (p['tMax'] as num).toDouble(),
            tMin: (p['tMin'] as num).toDouble(),
            pluie: (p['pluie'] as num).toDouble(),
          );
        }).toList(),
      );
    }

    // Lecture des données reçues depuis l'API Open-Meteo
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final tMax = daily['temperature_2m_max'] as List<dynamic>;
    final tMin = daily['temperature_2m_min'] as List<dynamic>;
    final pluie = daily['precipitation_sum'] as List<dynamic>;

    final List<PrevisionJour> listePrevisions = [];

    for (var i = 0; i < dates.length; i++) {
      listePrevisions.add(
        PrevisionJour(
          date: DateTime.parse(dates[i] as String),
          tMax: (tMax[i] as num).toDouble(),
          tMin: (tMin[i] as num).toDouble(),
          pluie: (pluie[i] as num).toDouble(),
        ),
      );
    }

    return Meteo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humiditeAir: (current['relative_humidity_2m'] as num).round(),
      vent: (current['wind_speed_10m'] as num).toDouble(),
      previsions: listePrevisions,
    );
  }
}
