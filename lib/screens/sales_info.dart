import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html' as html;
import 'dart:async';

// Add the missing ExportUtils class
class ExportUtils {
  static Future<void> exportToExcel({
    required BuildContext context,
    required List<Map<String, dynamic>> data,
    required List<ColumnDef> columnDefs,
    required String fileNamePrefix,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data'];

      // Add headers
      sheet.appendRow(columnDefs.map((col) => col.header).toList());

      // Add data rows
      for (var row in data) {
        sheet.appendRow(columnDefs.map((col) {
          final value = row[col.key]?.toString() ?? '';
          return value;
        }).toList());
      }

      final encodedBytes = excel.encode();
      final fileName = '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        // final blob = html.Blob([encodedBytes]);
        // final url = html.Url.createObjectUrlFromBlob(blob);
        // final anchor = html.AnchorElement(href: url)
        //   ..setAttribute('download', fileName)
        //   ..click();
        // html.Url.revokeObjectUrl(url);
      } else {
        await requestStoragePermission();

        final dir = await getApplicationDocumentsDirectory();
        final filePath = p.join(dir.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(encodedBytes!);
        await Share.shareXFiles([XFile(file.path)], text: fileNamePrefix);
      }
    } catch (e) {
      print("Error exporting to Excel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  static Future<void> requestStoragePermission() async {
    if (kIsWeb) return;

    final status = await Permission.storage.status;
    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (!result.isGranted) {
        print("Storage permission denied.");
        if (result.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    }
  }
}

class ColumnDef {
  final String header;
  final String key;
  final TextAlign alignment;

  ColumnDef(this.header, this.key, this.alignment);
}