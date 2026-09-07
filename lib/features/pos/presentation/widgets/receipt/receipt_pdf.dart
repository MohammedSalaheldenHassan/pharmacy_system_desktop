import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pharmacy_system/features/pos/data/sale_model.dart';

/// The app already bundles the Cairo font for Arabic text (see
/// pubspec.yaml `fonts:`); reuse it here so the PDF renders Arabic glyphs
/// correctly instead of the base PDF fonts, which don't support Arabic.
Future<pw.Font> _loadArabicFont() async {
  final data = await rootBundle.load('assets/font/Cairo-VariableFont_slnt,wght.ttf');
  return pw.Font.ttf(data);
}

/// Pharmacy name shown on the receipt header, matching the branding
/// already used across the app (login screen, POS app bar).
const String pharmacyDisplayName = 'صيدلية الشفاء';

/// Fixed 80mm thermal-receipt page width; height grows with content.
final PdfPageFormat _receiptPageFormat = PdfPageFormat(
  80 * PdfPageFormat.mm,
  double.infinity,
  marginAll: 4 * PdfPageFormat.mm,
);

String _formatDateTime(DateTime dateTime) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} '
      '${two(dateTime.hour)}:${two(dateTime.minute)}';
}

String _money(double value) => value.toStringAsFixed(2);

/// Builds the receipt PDF bytes for a completed [sale]. The layout is a
/// single fixed-width (80mm) thermal-receipt page built entirely from the
/// real sale data — no hardcoded amounts or items.
Future<Uint8List> buildReceiptPdfBytes(SaleModel sale) async {
  final arabicFont = await _loadArabicFont();
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
  );

  doc.addPage(
    pw.Page(
      pageFormat: _receiptPageFormat,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(
                pharmacyDisplayName,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'فاتورة بيع',
                style: const pw.TextStyle(fontSize: 10),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 8),
            _kv('رقم الفاتورة', sale.invoiceNumber),
            _kv('التاريخ والوقت', _formatDateTime(sale.dateTime)),
            _kv('الكاشير', sale.cashierName),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 0.6),
            pw.Row(
              // Reversed so the item name lands rightmost, matching RTL
              // reading order (this widget set has no Row textDirection).
              children: [
                pw.Expanded(flex: 2, child: _cellHeader('إجمالي')),
                pw.Expanded(flex: 2, child: _cellHeader('سعر')),
                pw.Expanded(flex: 1, child: _cellHeader('كمية')),
                pw.Expanded(flex: 3, child: _cellHeader('الصنف')),
              ],
            ),
            pw.Divider(thickness: 0.6),
            ...sale.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(flex: 2, child: _cell(_money(item.lineTotal))),
                    pw.Expanded(flex: 2, child: _cell(_money(item.unitPrice))),
                    pw.Expanded(flex: 1, child: _cell('${item.quantity}')),
                    pw.Expanded(flex: 3, child: _cell(item.name)),
                  ],
                ),
              ),
            ),
            pw.Divider(thickness: 0.6),
            _kv('المجموع الفرعي', _money(sale.subtotal)),
            _kv('الخصم', _money(sale.discount)),
            _kv('الضريبة', _money(sale.tax)),
            pw.Divider(thickness: 0.6),
            _kv('الإجمالي', _money(sale.total), bold: true),
            pw.SizedBox(height: 6),
            _kv('طريقة الدفع', sale.paymentMethod),
            _kv('المبلغ المدفوع', _money(sale.amountPaid)),
            _kv('المتبقي/الباقي', _money(sale.change)),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'شكراً لزيارتكم',
                style: const pw.TextStyle(fontSize: 10),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}

pw.Widget _kv(String label, String value, {bool bold = false}) {
  final style = pw.TextStyle(
    fontSize: bold ? 11 : 9,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      // Value first so the label lands on the right, matching RTL reading.
      children: [
        pw.Text(value, style: style, textDirection: pw.TextDirection.rtl),
        pw.Text(label, style: style, textDirection: pw.TextDirection.rtl),
      ],
    ),
  );
}

pw.Widget _cellHeader(String text) => pw.Text(
      text,
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      textDirection: pw.TextDirection.rtl,
    );

pw.Widget _cell(String text) => pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9),
      textDirection: pw.TextDirection.rtl,
    );
