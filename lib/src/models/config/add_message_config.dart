import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../../typedefs.dart';

/// {@template flutter_chatview_db_connection.AddMessageConfig}
/// Configuration class for handling message uploads.
///
/// This class allows defining whether images and voice messages
/// should be uploaded to storage, along with specifying a callback function
/// for handling the upload process.
/// {@endtemplate}
class AddMessageConfig {
  /// Creates an instance of [AddMessageConfig].
  ///
  /// - (required): [uploadImageToStorage]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.uploadImageToStorage}
  ///
  /// - (required): [uploadVoiceToStorage]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.uploadVoiceToStorage}
  ///
  /// - (required): [uploadDocument]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.uploadDocument}
  ///
  /// - (optional): [uploadPath]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.uploadPath}
  ///
  /// - (optional): [imageName]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.imageName}
  ///
  /// - (optional): [voiceName]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig.voiceName}
  const AddMessageConfig({
    required this.uploadImageToStorage,
    required this.uploadVoiceToStorage,
    required this.uploadDocument,
    this.uploadPath,
    this.imageName,
    this.voiceName,
  });

  /// {@template flutter_chatview_db_connection.AddMessageConfig.uploadImageToStorage}
  /// Whether the image should be uploaded on the storage or not.
  /// specifies `true` to enable it to upload image on the storage.
  /// {@endtemplate}
  final bool uploadImageToStorage;

  /// {@template flutter_chatview_db_connection.AddMessageConfig.uploadVoiceToStorage}
  /// Whether the voice should be uploaded on the storage or not.
  /// specifies `true` to enable it to upload voice on the storage.
  /// {@endtemplate}
  final bool uploadVoiceToStorage;

  /// {@template flutter_chatview_db_connection.AddMessageConfig.uploadDocument}
  /// callback function for uploading image or voice documents to cloud storage.
  /// {@endtemplate}
  final UploadDocumentCallback uploadDocument;

  /// {@template flutter_chatview_db_connection.AddMessageConfig.uploadPath}
  /// The path to store image at that directory on the storage.
  /// {@endtemplate}
  final String? uploadPath;

  /// {@template flutter_chatview_db_connection.AddMessageConfig.imageName}
  /// The image name to be used when storing the image in the storage.
  /// {@endtemplate}
  /// {@macro flutter_chatview_db_connection.StorageService.getFileName}
  final String? imageName;

  /// {@template flutter_chatview_db_connection.AddMessageConfig.voiceName}
  /// The voice name to be used when storing the voice in the storage.
  /// {@endtemplate}
  /// {@macro flutter_chatview_db_connection.StorageService.getFileName}
  final String? voiceName;

  /// Uploads an image or voice message to storage if enabled and
  /// returns the file URL or `null`.
  Future<String?> uploadDocumentFromMessage(Message message) async {
    return switch (message.messageType) {
      MessageType.image when uploadImageToStorage => uploadDocument(
          message,
          uploadPath: uploadPath,
          fileName: imageName,
        ),
      MessageType.voice when uploadVoiceToStorage => uploadDocument(
          message,
          uploadPath: uploadPath,
          fileName: voiceName,
        ),
      _ => null,
    };
  }
}
