// class Fournisseur {
//   int? idFournisseur;
//   String? idRecord;
//   String? nom;
//   double? longitude;
//   double? latitude;
//   String? adresse;
//   String? localisation;
//   String? tel;

//   Fournisseur({
//     this.idFournisseur,
//     this.idRecord,
//     this.nom,
//     this.longitude,
//     this.latitude,
//     this.adresse,
//     this.localisation,
//     this.tel,
//   });

//   factory Fournisseur.fromJson(Map<String, dynamic> json) {
//     return Fournisseur(
//       idFournisseur: json['idFournisseur'],
//       idRecord: json['id_record'],
//       nom: json['nom'],
//       longitude: json['longitude'],
//       latitude: json['latitude'],
//       adresse: json['adresse'],
//       localisation: json['localisation'],
//       tel: json['tel'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'idFournisseur': idFournisseur,
//       'id_record': idRecord,
//       'nom': nom,
//       'longitude': longitude,
//       'latitude': latitude,
//       'adresse': adresse,
//       'localisation': localisation,
//       'tel': tel,
//     };
//   }
// }
