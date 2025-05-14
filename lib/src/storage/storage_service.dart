import 'package:chatview_utils/chatview_utils.dart';

/// Defined different methods to interact with a cloud storage service.
abstract interface class StorageService {
  const StorageService._();

  /// Uploads an image or voice media from a [Message] to Cloud Storage.
  ///
  /// The file is stored in the specified directory path with a generated
  /// or provided file name.
  ///
  /// Once the upload is successful, the method returns the media's URL.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry the upload in case of
  /// failure.
  /// - (required): [message] Containing the media to upload.
  /// - (required): [chatId] The unique identifier of the chat where the
  /// media belongs.
  /// - (optional): [path] Specifies the directory path in Cloud Storage
  /// where the file will be stored.
  /// - (optional): [fileName] Specifies the name of the media file.
  /// (including the file's extension)
  ///
  /// **Returns:** A [Future] that resolves to the download URL of the uploaded
  /// media, or `null` if the upload fails.
  ///
  /// {@macro chatview_connect.StorageService.getFileName}
  Future<String?> uploadMedia({
    required int retry,
    required Message message,
    required String chatId,
    String? path,
    String? fileName,
  });

  /// Deletes a media from Cloud Storage.
  ///
  /// **Parameters:**
  /// - (required): The [Message] containing the media to be deleted.
  ///
  /// **Returns:** A [Future] that resolves to `true`
  /// if the media is successfully deleted, otherwise `false`.
  Future<bool> deleteMedia(Message message);

  /// Deletes all documents related to the specified chat, including any images
  /// or voice messages shared within the chat.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat whose documents
  /// will be deleted.
  ///
  /// Returns a true/false indicating whether the deletion was successful.
  Future<bool> deleteAllMedia(String chatId);
}
