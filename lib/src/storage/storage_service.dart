import 'package:flutter_chatview_models/flutter_chatview_models.dart';

/// Defined different methods to interact with a cloud storage service.
abstract interface class StorageService {
  const StorageService._();

  /// Uploads an image or voice document from a [Message] to a specified
  /// directory path with an file name in Cloud Storage and returns doc's URL.
  ///
  /// (optional): [uploadPath] specify how file will be stored in database.
  /// {@macro flutter_chatview_db_connection.StorageService.getDirectoryPath}
  ///
  /// (optional): [fileName] specify document name.
  /// {@macro flutter_chatview_db_connection.StorageService.getFileName}
  Future<String?> uploadDoc(
    Message message, {
    String? uploadPath,
    String? fileName,
  });

  /// Delete document from the Cloud Storage and returns a [bool] value
  /// true if its deleted.
  Future<bool> deleteDoc(Message message);
}
