import 'package:flutter_chatview_models/flutter_chatview_models.dart';

/// Defined different methods to interact with a cloud storage service.
abstract interface class StorageService {
  const StorageService._();

  /// Uploads an image or voice document from a [Message] to Cloud Storage.
  ///
  /// The file is stored in the specified directory path with a generated
  /// or provided file name.
  ///
  /// Once the upload is successful, the method returns the document's URL.
  ///
  /// **Parameters:**
  /// - (required): [message] Containing the document to upload.
  /// - (required): [chatId] The unique identifier of the chat where the
  /// document belongs.
  /// - (optional): [uploadPath] Specifies the directory path in Cloud Storage
  /// where the file will be stored.
  /// - (optional): [fileName] Specifies the name of the document file.
  /// (including the file's extension)
  ///
  /// **Returns:** A [Future] that resolves to the download URL of the uploaded
  /// document, or `null` if the upload fails.
  ///
  /// {@macro flutter_chatview_db_connection.StorageService.getFileName}
  Future<String?> uploadDoc({
    required Message message,
    required String chatId,
    String? uploadPath,
    String? fileName,
  });

  /// Deletes a document from Cloud Storage.
  ///
  /// **Parameters:**
  /// - (required): The [Message] containing the document to be deleted.
  ///
  /// **Returns:** A [Future] that resolves to `true`
  /// if the document is successfully deleted, otherwise `false`.
  Future<bool> deleteDoc(Message message);

  /// Deletes all documents related to the specified chat, including any images
  /// or voice messages shared within the chat.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat whose documents
  /// will be deleted.
  ///
  /// Returns a true/false indicating whether the deletion was successful.
  Future<bool> deleteChatMedia(String chatId);
}
