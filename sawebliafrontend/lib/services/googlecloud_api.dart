import "dart:typed_data";

import "package:gcloud/storage.dart";
import "package:googleapis_auth/auth_io.dart" as auth;
import "package:mime/mime.dart";

class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  late auth.AutoRefreshingAuthClient _client;

  CloudApi(String json)
      : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    // Create a client

    _client = await auth.clientViaServiceAccount(_credentials, Storage.SCOPES);

    // Instantiate objects to cloud storage
    var storage = Storage(_client, 'Project Name');
    var bucket = storage.bucket('bucket_name');

    // Save to bucket
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final type =
        lookupMimeType(name); // FOR CLOUD STORAGE TO BE ABLE TO READ THE FILE
    return await bucket.writeBytes(name, imgBytes,
        metadata: ObjectMetadata(
          contentType: type,
          custom: {
            // OPTIONAL : CUSTOM META DATA
            'timestamp': '$timestamp',
          },
        ));
  }
}
