import 'Artisan.dart';

import 'Fournisseur.dart';

class Mission {
  int? idMission;
  List<Artisan>? artisans;
  //Fournisseur? fournisseur;
  String? idRecord;
  String? envoyerNotif;
  String? autoAffectation;
  double? longitude;
  double? latitude;
  String? localisation;
  String? adresse;
  String? quartier;
  String? statutMission;
  String? typeMission;
  String? ponctualite;
  String? description;
  bool? urgence;
  String? metier;
  DateTime? debutPrevu;
  DateTime? debutReel;
  DateTime? finPrevue;
  DateTime? finReelle;
  double? prixMaxFournitures;
  double? prixAAPayer;
  String? moyenPaiement;
  bool? notificationSent;
  String? telClient;
  String? nomClient;
  bool? paiementCollecte;
  bool? giveBonus;

  Mission(
      {this.idMission,
      this.artisans,
      //this.fournisseur,
      this.idRecord,
      this.envoyerNotif,
      this.autoAffectation,
      this.longitude,
      this.latitude,
      this.localisation,
      this.adresse,
      this.quartier,
      this.statutMission,
      this.typeMission,
      this.ponctualite,
      this.description,
      this.metier,
      this.urgence,
      this.debutPrevu,
      this.debutReel,
      this.finPrevue,
      this.finReelle,
      this.prixMaxFournitures,
      this.prixAAPayer,
      this.moyenPaiement,
      this.notificationSent,
      this.nomClient,
      this.telClient,
      this.paiementCollecte,
      this.giveBonus});

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
        idMission: json['idMission'],
        artisans:
            (json['artisans'] as List).map((a) => Artisan.fromJson(a)).toList(),
        // fournisseur: json['fournisseur'] != null
        //     ? Fournisseur.fromJson(json['fournisseur'])
        //     : null,
        idRecord: json['id_record'],
        envoyerNotif: json['envoyerNotif'],
        autoAffectation: json['autoAffectation'],
        longitude: json['longitude'],
        latitude: json['latitude'],
        localisation: json['localisation'],
        adresse: json['adresse'],
        quartier: json['quartier'],
        statutMission: json['statutMission'],
        typeMission: json['typeMission'],
        ponctualite: json['ponctualite'],
        description: json['description'],
        urgence: json['urgence'],
        // metiers: (json['metiers'] as List<dynamic>?)?.cast<String>(),

        // metiers:
        //     json['metiers'] != null ? List<String>.from(json['metiers']) : null,

        metier: json['metier'],
        debutPrevu: json['debutPrevu'] != null
            ? DateTime.parse(json['debutPrevu'])
            : null,
        debutReel: json['debutReel'] != null
            ? DateTime.parse(json['debutReel'])
            : null,
        finPrevue: json['finPrevue'] != null
            ? DateTime.parse(json['finPrevue'])
            : null,
        finReelle: json['finReelle'] != null
            ? DateTime.parse(json['finReelle'])
            : null,
        prixMaxFournitures: json['prixMaxFournitures'],
        prixAAPayer: json['prixAAPayer'],
        moyenPaiement: json['moyenPaiement'],
        notificationSent: json['notificationSent'],
        nomClient: json['nomClient'],
        telClient: json['telClient'],
        paiementCollecte: json['paiementCollecte'],
        giveBonus: json['giveBonus']);
  }
  Map<String, dynamic> toJson() {
    return {
      'idMission': idMission,
      //'fournisseur': fournisseur?.toJson(),
      'artisans': artisans?.map((a) => a.toJson()).toList(),
      'id_record': idRecord,
      'envoyerNotif': envoyerNotif,
      'longitude': longitude,
      'latitude': latitude,
      'localisation': localisation,
      'adresse': adresse,
      'quartier': quartier,
      'statutMission': statutMission,
      'typeMission': typeMission,
      'ponctualite': ponctualite,
      'description': description,
      'urgence': urgence,
      //'metiers': List<dynamic>.from(metiers?.cast<dynamic>() ?? []),
      'metier': metier,
      'debutReel': debutReel?.toIso8601String(),
      'finPrevue': finPrevue?.toIso8601String(),
      'finReelle': finReelle?.toIso8601String(),
      'prixMaxFournitures': prixMaxFournitures,
      'prixAAPayer': prixAAPayer,
      'moyenPaiement': moyenPaiement,
      'telClient': telClient,
      'nomClient': nomClient,
      'notificationSent': notificationSent,
      'paiementCollecte': paiementCollecte,
      'giveBonus': giveBonus
    };
  }
}
