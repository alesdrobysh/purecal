class NoDataToExportException implements Exception {
  final String message;

  NoDataToExportException([this.message = 'No data available to export']);

  @override
  String toString() => message;
}

class NoProductsToExportException implements Exception {
  final String message;

  NoProductsToExportException(
      [this.message = 'No local products available to export']);

  @override
  String toString() => message;
}
