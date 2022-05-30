class EticonDownloadError implements Exception {
  String error;

  EticonDownloadError({required this.error});

  @override
  String toString() {
    var message = this.error;
    return "\n[EticonDownloadError]: $message";
  }

  @override
  String? get message => this.error;
}

class DownloadException implements Exception {
  int code;

  dynamic body;

  DownloadException(this.code, {this.body});

  @override
  String toString() {
    return '\n[DownloadException] Error code: $code, Error body: ${body.toString()}';
  }
}
