// lib/data/models/pdf_file.dart

import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as path;

class PdfFile extends Equatable {
  final String name;
  final String path;
  final int size;
  final DateTime lastModified;
  final int? pageCount;
  final File? file;
  final String? mimeType;
  final String? extension;
  final String? serverUrl;

  const PdfFile({
    required this.name,
    required this.path,
    required this.size,
    required this.lastModified,
    this.pageCount,
    this.file,
    this.mimeType,
    this.extension,
    this.serverUrl,
  });

  // Factory to create PdfFile from a File object
  factory PdfFile.fromFile(File file) {
    return PdfFile(
      name: path.basename(file.path),
      path: file.path,
      size: file.lengthSync(),
      lastModified: file.lastModifiedSync(),
      file: file,
      extension: path.extension(file.path).toLowerCase().replaceFirst('.', ''),
      mimeType: _getMimeType(path.extension(file.path)),
    );
  }

  // Factory to create PdfFile from a network file
  factory PdfFile.fromNetwork({
    required String name,
    required String url,
    required int size,
    int? pageCount,
  }) {
    return PdfFile(
      name: name,
      path: url,
      size: size,
      lastModified: DateTime.now(),
      pageCount: pageCount,
      serverUrl: url,
      extension: path.extension(name).toLowerCase().replaceFirst('.', ''),
      mimeType: _getMimeType(path.extension(name)),
    );
  }

  // Get mime type based on file extension
  static String _getMimeType(String extension) {
    final ext = extension.toLowerCase().replaceFirst('.', '');
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  // Get file size in human-readable format
  String get formattedSize {
    final kb = 1024;
    final mb = kb * 1024;
    final gb = mb * 1024;

    if (size >= gb) {
      return '${(size / gb).toStringAsFixed(2)} GB';
    } else if (size >= mb) {
      return '${(size / mb).toStringAsFixed(2)} MB';
    } else if (size >= kb) {
      return '${(size / kb).toStringAsFixed(2)} KB';
    } else {
      return '$size B';
    }
  }

  // Check if file is a PDF
  bool get isPdf => extension == 'pdf';

  // Check if file is an image
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif'].contains(extension);

  // Check if file is a document
  bool get isDocument => ['doc', 'docx', 'txt', 'rtf'].contains(extension);

  // Check if file is a spreadsheet
  bool get isSpreadsheet => ['xls', 'xlsx', 'csv'].contains(extension);

  // Check if file is a presentation
  bool get isPresentation => ['ppt', 'pptx'].contains(extension);

  // Create a copy with updated fields
  PdfFile copyWith({
    String? name,
    String? path,
    int? size,
    DateTime? lastModified,
    int? pageCount,
    File? file,
    String? mimeType,
    String? extension,
    String? serverUrl,
  }) {
    return PdfFile(
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      pageCount: pageCount ?? this.pageCount,
      file: file ?? this.file,
      mimeType: mimeType ?? this.mimeType,
      extension: extension ?? this.extension,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }

  @override
  List<Object?> get props => [
    name,
    path,
    size,
    lastModified,
    pageCount,
    mimeType,
    extension,
    serverUrl,
  ];
}
