class NotificationMessage {
  String? recipientToken;
  String title;
  String body;
  Map<String, String>? data;
  int? missionId;
  DateTime? receivedDate;

  NotificationMessage(
      {this.recipientToken,
      required this.title,
      required this.body,
      this.data,
      this.missionId,
      this.receivedDate});

  Map<String, dynamic> toJson() {
    return {
      'recipientToken': recipientToken,
      'title': title,
      'body': body,
      'missionId': missionId,
      'data': data,
      'receivedDate': receivedDate
    };
  }
}
