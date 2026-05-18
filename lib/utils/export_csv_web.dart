import 'dart:js_interop';
import 'package:web/web.dart' as web;

void exportarCSV(String csv, String filename) {
  final blob = web.Blob([csv.toJS].toJS, web.BlobPropertyBag(type: 'text/csv'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.setAttribute('download', filename);
  anchor.click();
  web.URL.revokeObjectURL(url);
}
