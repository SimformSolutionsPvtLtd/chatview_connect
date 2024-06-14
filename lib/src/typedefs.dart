import 'package:chatview/chatview.dart';

import 'database/database_service.dart';
import 'storage/storage_service.dart';

/// Callback function used for updating reactions.
/// - (optional): `userId` specifies id of the user who performed the reaction.
///
/// - (optional): `emoji` specifies emoji that user has used.
typedef UserReactionCallback = ({String userId, String emoji});

/// Record for storing database type wise services in single variable
typedef DatabaseTypeServicesRecord = ({
  DatabaseService database,
  StorageService storage,
});

/// Callback function for uploading document to cloud storage.
typedef UploadDocumentCallback = Future<String?> Function(
  Message message, {
  String? uploadPath,
  String? fileName,
});

/// Callback function for deleting document from storage.
typedef DeleteDocumentCallback = Future<bool> Function(Message message);
