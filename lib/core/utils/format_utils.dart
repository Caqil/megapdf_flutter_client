// lib/core/utils/format_utils.dart

import 'dart:math';
import 'package:intl/intl.dart';

class FormatUtils {
  // Format date
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date,
      {String format = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(format).format(date);
  }

  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Format currency
  static String formatCurrency(double amount,
      {String currencySymbol = '\$', int decimalPlaces = 2}) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: decimalPlaces,
    );
    return formatter.format(amount);
  }

  // Format percentage
  static String formatPercentage(double value, {int decimalPlaces = 1}) {
    final percentage = value * 100;
    final formatter = NumberFormat.percentPattern();
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, digitGroups)).toStringAsFixed(2)} ${units[digitGroups]}';
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber,
      {String format = '(xxx) xxx-xxxx'}) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If the input is not a valid phone number, return the original
    if (digitsOnly.isEmpty) return phoneNumber;

    var result = format;
    for (var i = 0; i < digitsOnly.length && i < format.length; i++) {
      result = result.replaceFirst('x', digitsOnly[i]);
    }

    // Remove any remaining placeholders
    result = result.replaceAll(RegExp(r'x'), '');

    return result;
  }

  // Format email address (to hide part of it)
  static String formatEmailAddress(String email, {bool hideEmail = true}) {
    if (!hideEmail) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return email;

    return '${name.substring(0, 2)}${name.substring(2).replaceAll(RegExp(r'.'), '*')}@$domain';
  }

  // Truncate string with ellipsis
  static String truncateString(String text, int maxLength,
      {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  // Format decimal number with specified precision
  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  // Format number with commas as thousands separators
  static String formatNumber(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  // Convert page ranges string to list of pages
  static List<int> parsePageRanges(String pageRanges, int totalPages) {
    final pages = <int>{};
    final ranges = pageRanges.split(',');

    for (final range in ranges) {
      final trimmedRange = range.trim();

      if (trimmedRange.isEmpty) continue;

      if (trimmedRange.contains('-')) {
        final parts = trimmedRange.split('-');
        if (parts.length != 2) continue;

        final start = int.tryParse(parts[0].trim());
        final end = int.tryParse(parts[1].trim());

        if (start == null || end == null) continue;
        if (start < 1 || end > totalPages || start > end) continue;

        for (var i = start; i <= end; i++) {
          pages.add(i);
        }
      } else {
        final page = int.tryParse(trimmedRange);
        if (page == null || page < 1 || page > totalPages) continue;
        pages.add(page);
      }
    }

    return pages.toList()..sort();
  }

  // Convert list of page numbers to compact ranges string
  static String formatPageRanges(List<int> pages) {
    if (pages.isEmpty) return '';

    final sortedPages = [...pages]..sort();
    final ranges = <String>[];

    int start = sortedPages[0];
    int end = start;

    for (var i = 1; i < sortedPages.length; i++) {
      if (sortedPages[i] == end + 1) {
        end = sortedPages[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = sortedPages[i];
        end = start;
      }
    }

    ranges.add(start == end ? '$start' : '$start-$end');

    return ranges.join(', ');
  }
}
