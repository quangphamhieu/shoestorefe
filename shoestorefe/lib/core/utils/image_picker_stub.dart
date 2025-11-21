// Stub file for web platform - ImagePicker is not available on web
class ImagePicker {
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
  }) async {
    throw UnsupportedError('ImagePicker is not supported on web platform');
  }
}

class XFile {
  final String path;
  XFile(this.path);
}

enum ImageSource { gallery, camera }
