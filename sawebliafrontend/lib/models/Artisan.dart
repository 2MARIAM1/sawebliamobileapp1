import 'Mission.dart';

class Artisan {
  int? idArtisan;
  String? idRecord;
  List<Mission>? missions;
  String? email;
  String? password;
  String? nomComplet;
  String? cin;
  String? tel;
  double? longitude;
  double? latitude;
  String? adresse;
  String? localisation;
  String? quartier;
  bool? jocker;
  int? nbrMissions;
  double? totalCa;
  double? totalBonus;
  int? nbrRetards;
  DateTime? lastLogin;
  bool? blocked;
  List<String?>? metiers;
  String? fcmToken;

  Artisan({
    this.idArtisan,
    this.idRecord,
    this.missions,
    this.email,
    this.password,
    this.nomComplet,
    this.cin,
    this.tel,
    this.longitude,
    this.latitude,
    this.adresse,
    this.localisation,
    this.quartier,
    this.jocker,
    this.nbrMissions,
    this.totalCa,
    this.totalBonus,
    this.nbrRetards,
    this.lastLogin,
    this.blocked,
    this.metiers,
    this.fcmToken,
  })
  // : super(
  //         id: id,
  //         email: email,
  //         password: password,
  //         userType: userType,)

  ;

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      idArtisan: json['idArtisan'],
      //  missions:
      //    (json['missions'] as List).map((a) => Mission.fromJson(a)).toList(),
      idRecord: json['id_record'],
      email: json['login'],
      password: json['password'],
      nomComplet: json['nomComplet'],
      cin: json['cin'],
      tel: json['tel'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      adresse: json['adresse'],
      localisation: json['localisation'],
      quartier: json['quartier'],
      jocker: json['jocker'],
      nbrMissions: json['nbrMissions'],
      totalCa: json['totalCa'],
      totalBonus: json['totalBonus'],
      nbrRetards: json['nbrRetards'],
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      blocked: json['blocked'],
      metiers: (json['metiers'] as List<dynamic>?)?.cast<String>(),

      //  metiers: List<String?>.from(json['metiers']),
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idArtisan': idArtisan,
      'missions': missions?.map((mission) => mission.toJson()).toList(),
      'id_record': idRecord,
      'login': email,
      'password': password,
      'nomComplet': nomComplet,
      'cin': cin,
      'tel': tel,
      'longitude': longitude,
      'latitude': latitude,
      'adresse': adresse,
      'localisation': localisation,
      'quartier': quartier,
      'jocker': jocker,
      'nbrMissions': nbrMissions,
      'totalCa': totalCa,
      'totalBonus': totalBonus,
      'nbrRetards': nbrRetards,
      'lastLogin': lastLogin?.toIso8601String(), // Convert DateTime to string
      'blocked': blocked,
      'metiers': List<dynamic>.from(metiers?.cast<dynamic>() ?? []),

      // 'metiers':
      //     List<dynamic>.from(metiers as Iterable), // Convert List to dynamic
      'fcmToken': fcmToken,
    };
  }
}
