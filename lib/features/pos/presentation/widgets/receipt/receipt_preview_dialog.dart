import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pharmacy_system/features/pos/data/sale_model.dart';
import 'package:pharmacy_system/features/pos/presentation/widgets/receipt/receipt_pdf.dart';

/// Shown automatically after a successful checkout. Renders the receipt
/// generated from the completed [sale] and lets the cashier preview it and
/// send it to a real printer (or close without printing).
class ReceiptPreviewDialog extends StatelessWidget {
  const ReceiptPreviewDialog({super.key, required this.sale});

  final SaleModel sale;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'معاينة الفاتورة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  Text(
                    sale.invoiceNumber,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: PdfPreview(
                build: (format) => buildReceiptPdfBytes(sale),
                allowPrinting: true,
                allowSharing: true,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                useActions: true,
                pdfFileName: '${sale.invoiceNumber}.pdf',
                loadingWidget: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
