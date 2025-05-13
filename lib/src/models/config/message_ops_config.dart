import 'package:chatview_models/chatview_models.dart';

import '../../typedefs.dart';

/// {@template chatview_connect.MessageOpsConfig}
/// Configuration class for handling message uploads.
///
/// This class allows defining whether images and voice messages should be
/// uploaded to or deleted from storage, along with specifying a callback
/// function for handling the upload process.
/// {@endtemplate}
class MessageOpsConfig {
  /// Creates an instance of [MessageOpsConfig].
  ///
  /// - (required): [syncImageWithStorage]
  /// {@macro chatview_connect.MessageOpsConfig.syncImageWithStorage}
  ///
  /// - (required): [syncVoiceWithStorage]
  /// {@macro chatview_connect.MessageOpsConfig.syncVoiceWithStorage}
  ///
  /// - (required): [onUploadMedia]
  /// {@macro chatview_connect.MessageOpsConfig.onUploadMedia}
  ///
  /// - (required): [onDeleteMedia]
  /// {@macro chatview_connect.MessageOpsConfig.onDeleteMedia}
  ///
  /// - (optional): [uploadPath]
  /// {@macro chatview_connect.MessageOpsConfig.uploadPath}
  ///
  /// - (optional): [imageName]
  /// {@macro chatview_connect.MessageOpsConfig.imageName}
  ///
  /// - (optional): [voiceName]
  /// {@macro chatview_connect.MessageOpsConfig.voiceName}
  const MessageOpsConfig({
    required this.syncImageWithStorage,
    required this.syncVoiceWithStorage,
    required this.onUploadMedia,
    required this.onDeleteMedia,
    this.uploadPath,
    this.imageName,
    this.voiceName,
  });

  /// {@template chatview_connect.MessageOpsConfig.syncImageWithStorage}
  /// Determines whether the image should be uploaded to or deleted from storage
  /// - Set to `true` to enable automatic upload and deletion in storage.
  /// - Set to `false` to prevent any modifications in storage.
  /// {@endtemplate}
  final bool syncImageWithStorage;

  /// {@template chatview_connect.MessageOpsConfig.syncVoiceWithStorage}
  /// Determines whether the voice should be uploaded to or deleted from storage
  /// - Set to `true` to enable automatic upload and deletion in storage.
  /// - Set to `false` to prevent any modifications in storage.
  /// {@endtemplate}
  final bool syncVoiceWithStorage;

  /// {@template chatview_connect.MessageOpsConfig.onUploadMedia}
  /// callback function for uploading image or voice documents to cloud storage.
  /// {@endtemplate}
  final UploadMediaCallback onUploadMedia;

  /// {@template chatview_connect.MessageOpsConfig.onDeleteMedia}
  /// callback function for deleting image or voice document from cloud storage.
  /// from database.
  /// {@endtemplate}
  final DeleteMediaCallback onDeleteMedia;

  /// {@template chatview_connect.MessageOpsConfig.uploadPath}
  /// The path to store image at that directory on the storage.
  /// {@endtemplate}
  final String? uploadPath;

  /// {@template chatview_connect.MessageOpsConfig.imageName}
  /// The image name to be used when storing the image in the storage.
  /// {@endtemplate}
  /// {@macro chatview_connect.StorageService.getFileName}
  final String? imageName;

  /// {@template chatview_connect.MessageOpsConfig.voiceName}
  /// The voice name to be used when storing the voice in the storage.
  /// {@endtemplate}
  /// {@macro chatview_connect.StorageService.getFileName}
  final String? voiceName;

  /// Deletes an image or voice message from storage if enabled and
  /// returns `true` if the deletion was successful, otherwise `false`.
  Future<bool> deleteMedia(Message message) {
    return switch (message.messageType) {
      MessageType.image when syncImageWithStorage => onDeleteMedia(message),
      MessageType.voice when syncVoiceWithStorage => onDeleteMedia(message),
      _ => Future.value(false),
    };
  }

  /// Uploads an image or voice message to storage if enabled and
  /// returns the file URL or `null`.
  Future<String?> uploadMedia(Message message) {
    return switch (message.messageType) {
      MessageType.image when syncImageWithStorage => onUploadMedia(
          message,
          uploadPath: uploadPath,
          fileName: imageName,
        ),
      MessageType.voice when syncVoiceWithStorage => onUploadMedia(
          message,
          uploadPath: uploadPath,
          fileName: voiceName,
        ),
      _ => Future.value(),
    };
  }
}
