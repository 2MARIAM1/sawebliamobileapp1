class FormSubmission {
  double prixTotalEstime;
  double prixMainDOeuvre;
  double prixEstimeFournitures;
  int dureeEstimee;
  String missionId;

  FormSubmission({
    required this.prixTotalEstime,
    required this.prixMainDOeuvre,
    required this.prixEstimeFournitures,
    required this.dureeEstimee,
    required this.missionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Prix total estimé': prixTotalEstime,
      "Prix main d'oeuvre": prixMainDOeuvre,
      'Prix estimé fournitures': prixEstimeFournitures,
      'Durée estimée': dureeEstimee,
      'Missions App Mobile': [missionId],
    };
  }
}
