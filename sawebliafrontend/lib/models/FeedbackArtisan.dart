import 'package:sawebliafrontend/models/Mission.dart';

class FeedbackArtisan {
  int? idFeedback;
  Mission? mission;
  String? typeFichier;
  String? nomFichier;
  String? url;

  FeedbackArtisan({
    this.idFeedback,
    this.mission,
    this.typeFichier,
    this.nomFichier,
    this.url,
  });

  factory FeedbackArtisan.fromJson(Map<String, dynamic> json) {
    return FeedbackArtisan(
      idFeedback: json['idFeedback'],
      mission:
          json['mission'] != null ? Mission.fromJson(json['mission']) : null,
      typeFichier: json['typeFichier'],
      nomFichier: json['nomFichier'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idFeedback': idFeedback,
      "mission": mission?.toJson(),
      'typeFichier': typeFichier,
      'nomFichier': nomFichier,
      'url': url,
    };
  }
}
