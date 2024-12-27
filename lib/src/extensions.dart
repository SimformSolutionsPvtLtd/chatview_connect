/// Extension methods for the `String` class.
extension StringExtension on String {
  /// To get image's directory path from the Firebase's Download URL
  String? get fullPath {
    return split('o/')
        .lastOrNull
        ?.split('?')
        .firstOrNull
        ?.replaceAll('%2F', '/');
  }
}
