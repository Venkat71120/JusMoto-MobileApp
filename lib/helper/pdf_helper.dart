import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/admin_models/AdminReportModels.dart';
import 'package:intl/intl.dart';

class PdfHelper {
  static Future<void> generateRevenuePdf(List<AdminRevenueReportItem> report, String from, String to) async {
    final pdf = pw.Document();

    final totalOrders = report.fold(0, (s, r) => s + r.orderCount);
    final totalRevenue = report.fold(0.0, (s, r) => s + r.totalRevenue);
    final totalPaid = report.fold(0.0, (s, r) => s + r.paidRevenue);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader("REVENUE REPORT", "Period: $from to $to"),
          pw.SizedBox(height: 20),
          _buildSummary([
            _SummaryItem("Total Orders", totalOrders.toString()),
            _SummaryItem("Total Revenue", "Rs ${totalRevenue.toStringAsFixed(0)}"),
            _SummaryItem("Paid Revenue", "Rs ${totalPaid.toStringAsFixed(0)}"),
          ]),
          pw.SizedBox(height: 20),
          _buildRevenueTable(report),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> generateOrderPdf(List<AdminOrderReportItem> report) async {
    final pdf = pw.Document();

    final totalCount = report.fold(0, (s, r) => s + r.count);
    final totalAmount = report.fold(0.0, (s, r) => s + r.totalAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader("ORDER STATUS REPORT", "Generated on: ${DateFormat('dd MMM yyyy').format(DateTime.now())}"),
          pw.SizedBox(height: 20),
          _buildSummary([
            _SummaryItem("Total Orders", totalCount.toString()),
            _SummaryItem("Total Value", "Rs ${totalAmount.toStringAsFixed(0)}"),
          ]),
          pw.SizedBox(height: 20),
          _buildOrderTable(report),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("JusMoto Admin", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
        pw.SizedBox(height: 4),
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(subtitle, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(thickness: 2, color: PdfColors.red900),
      ],
    );
  }

  static pw.Widget _buildSummary(List<_SummaryItem> items) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: items.map((item) => 
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            children: [
              pw.Text(item.label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.SizedBox(height: 4),
              pw.Text(item.value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        )
      ).toList(),
    );
  }

  static pw.Widget _buildRevenueTable(List<AdminRevenueReportItem> report) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red900),
      cellHeight: 30,
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Period', 'Orders', 'Total Revenue', 'Paid Revenue'],
      data: report.map((row) => [
        row.period,
        row.orderCount.toString(),
        "Rs ${row.totalRevenue.toStringAsFixed(0)}",
        "Rs ${row.paidRevenue.toStringAsFixed(0)}",
      ]).toList(),
    );
  }

  static pw.Widget _buildOrderTable(List<AdminOrderReportItem> report) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      cellHeight: 30,
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Status', 'Count', 'Total Amount'],
      data: report.map((row) => [
        row.statusLabel,
        row.count.toString(),
        "Rs ${row.totalAmount.toStringAsFixed(0)}",
      ]).toList(),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  const _SummaryItem(this.label, this.value);
}
