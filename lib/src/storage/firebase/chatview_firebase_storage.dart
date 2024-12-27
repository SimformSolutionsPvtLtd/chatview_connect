import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../extensions.dart';
import '../storage_service.dart';
import 'chatview_firebase_storage_refs.dart';

/// provides methods for uploading and deleting images from Firebase Storage.
final class ChatViewFirebaseStorage implements StorageService {
  static final _firebaseStorage = FirebaseStorage.instance.ref();

  static final _imageRef = _firebaseStorage.child(
    ChatViewFirebaseStorageRefs.images,
  );

  static final _voiceRef = _firebaseStorage.child(
    ChatViewFirebaseStorageRefs.voices,
  );

  @override
  Future<String?> uploadDoc(
    Message message, {
    String? uploadPath,
    String? fileName,
  }) async {
    switch (message.messageType) {
      case MessageType.image:
        return _uploadFile(
          message: message,
          ref: _imageRef,
          uploadPath: uploadPath,
          fileName: fileName,
        );
      case MessageType.voice:
        return _uploadFile(
          message: message,
          ref: _voiceRef,
          uploadPath: uploadPath,
          fileName: fileName,
        );
      case MessageType.text || MessageType.custom:
        return null;
    }
  }

  @override
  Future<bool> deleteDoc(Message message) async {
    switch (message.messageType) {
      case MessageType.image:
        return _deleteFile(
          message: message,
          filePath: message.message.fullPath,
        );
      case MessageType.voice:
        return _deleteFile(
          message: message,
          filePath: message.message.fullPath,
        );
      case MessageType.text || MessageType.custom:
        return false;
    }
  }

  /// {@template flutter_chatview_db_connection.StorageService.getFileName}
  /// by default it will follow below pattern from [Message].
  /// Example:
  /// ```dart
  /// Message(
  ///   id: '1',
  ///   message: "Hi!",
  ///   createdAt: DateTime(2024, 6, 25),
  ///   sendBy: '1',
  ///   status: MessageStatus.read,
  /// );
  /// Pattern: 'id_sendBy_createdAtTimestamp_fileName.fileExtension'
  /// Output: 1_1_1719253800000000_my_image.jpg
  /// ```
  /// {@endtemplate}
  String _getFileName(Message message) {
    final fileExtension = path.extension(message.message);
    final fileName = path.basenameWithoutExtension(message.message);
    final timestamp = message.createdAt.microsecondsSinceEpoch;
    return '${message.id}_${message.sentBy}_${timestamp}_$fileName$fileExtension';
  }

  /// {@template flutter_chatview_db_connection.StorageService.getDirectoryPath}
  /// by default it will use following path pattern: year/month/day/message_id
  /// Example:
  /// ```dart
  /// Message(
  ///   id: '1',
  ///   message: "Hi!",
  ///   createdAt: DateTime(2024, 6, 25),
  ///   sendBy: '1',
  ///   status: MessageStatus.read,
  /// );
  /// Pattern: year/month/date/id
  /// Output: 2024/6/25/1
  /// ```
  /// {@endtemplate}
  String _getDirectoryPath(Message message) {
    final messageId = message.id;
    final day = message.createdAt.day;
    final month = message.createdAt.month;
    final year = message.createdAt.year;
    final directoryPath = '$year/$month/$day/$messageId';
    return directoryPath;
  }

  Future<String?> _uploadFile({
    required Message message,
    required Reference ref,
    String? filePath,
    String? uploadPath,
    String? fileName,
  }) async {
    final file = File(filePath ?? message.message);
    final isFileExist = file.existsSync();
    if (!isFileExist) throw Exception('File Not Exist!');
    final directoryPath = uploadPath ?? _getDirectoryPath(message);
    final name = fileName ?? _getFileName(message);
    final fileRef = ref.child('$directoryPath/$name');
    await fileRef.putFile(file);
    return ref.getDownloadURL();
  }

  Future<bool> _deleteFile({
    required Message message,
    required String? filePath,
  }) async {
    if (filePath == null) {
      throw Exception('chatview: Unable to get path from message');
    }
    final imageRef = _firebaseStorage.child(filePath);
    await imageRef.delete();
    return true;
  }
}
