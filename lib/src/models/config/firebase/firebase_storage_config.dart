/// Configuration class for managing Firebase Storage settings,
/// including synchronization options for voice and image files.
class FirebaseStorageConfig {
  /// Creates a [FirebaseStorageConfig] instance with the required
  /// configurations.
  ///
  /// - [syncVoice] controls whether voice files should be stored in
  /// Firebase Storage.
  /// - [syncImage] controls whether image files should be stored in
  /// Firebase Storage.
  const FirebaseStorageConfig({
    required this.syncVoice,
    required this.syncImage,
  });

  /// Determines whether voice files should be uploaded to or deleted
  /// from storage.
  ///
  /// - Set to `true` to enable automatic upload and deletion in storage.
  /// - Set to `false` to prevent any modifications in storage.
  final bool syncVoice;

  /// Determines whether image files should be uploaded to or deleted
  /// from storage.
  ///
  /// - Set to `true` to enable automatic upload and deletion in storage.
  /// - Set to `false` to prevent any modifications in storage.
  final bool syncImage;
}
