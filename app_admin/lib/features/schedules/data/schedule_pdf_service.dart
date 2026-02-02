import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'dto/time_slot_dto.dart';

class SchedulePdfService {
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  /// Generate and print/preview PDF of doctor schedules
  static Future<void> printSchedules({
    required List<TimeSlotDto> slots,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = await _generatePdf(
      slots: slots,
      title: title,
      startDate: startDate,
      endDate: endDate,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'lich_lam_viec_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Generate PDF document
  static Future<pw.Document> _generatePdf({
    required List<TimeSlotDto> slots,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Load font for Vietnamese
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Group slots by doctor
    final slotsByDoctor = <String, List<TimeSlotDto>>{};
    for (final slot in slots) {
      final doctorKey = slot.doctorId;
      slotsByDoctor.putIfAbsent(doctorKey, () => []).add(slot);
    }

    // Sort each doctor's slots by date
    for (final doctorSlots in slotsByDoctor.values) {
      doctorSlots.sort((a, b) => a.date.compareTo(b.date));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          title: title,
          startDate: startDate,
          endDate: endDate,
          font: font,
          fontBold: fontBold,
        ),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          // Summary section
          _buildSummary(slots, slotsByDoctor.length, font, fontBold),
          pw.SizedBox(height: 20),

          // Table for each doctor
          ...slotsByDoctor.entries.map((entry) {
            final doctorSlots = entry.value;
            final doctorName = doctorSlots.first.doctorName ?? 'Bác sĩ';
            return _buildDoctorSection(doctorName, doctorSlots, font, fontBold);
          }),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader({
    required String title,
    DateTime? startDate,
    DateTime? endDate,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MEDIBOOK',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 24,
                      color: PdfColor.fromHex('#2E80FA'),
                    ),
                  ),
                  pw.Text(
                    'He thong quan ly lich kham benh',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColor.fromHex('#5F718C'),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Ngay in: ${_dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColor.fromHex('#5F718C'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F3F4F6'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 18,
                  ),
                ),
                if (startDate != null && endDate != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Tu ${_dateFormat.format(startDate)} den ${_dateFormat.format(endDate)}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColor.fromHex('#5F718C'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.Divider(color: PdfColor.fromHex('#E5E7EB')),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'MediBook Admin Portal',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: PdfColor.fromHex('#9CA3AF'),
            ),
          ),
          pw.Text(
            'Trang ${context.pageNumber}/${context.pagesCount}',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: PdfColor.fromHex('#9CA3AF'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(
    List<TimeSlotDto> slots,
    int doctorCount,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final pendingCount = slots.where((s) => s.status == 'PENDING').length;
    final approvedCount = slots.where((s) => s.status == 'APPROVED').length;
    final rejectedCount = slots.where((s) => s.status == 'REJECTED').length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tong so lich', slots.length.toString(), '#2E80FA', font, fontBold),
          _buildStatItem('Bac si', doctorCount.toString(), '#8B5CF6', font, fontBold),
          _buildStatItem('Cho duyet', pendingCount.toString(), '#F59E0B', font, fontBold),
          _buildStatItem('Da duyet', approvedCount.toString(), '#10B981', font, fontBold),
          _buildStatItem('Tu choi', rejectedCount.toString(), '#EF4444', font, fontBold),
        ],
      ),
    );
  }

  static pw.Widget _buildStatItem(
    String label,
    String value,
    String colorHex,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 20,
            color: PdfColor.fromHex(colorHex),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColor.fromHex('#5F718C'),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDoctorSection(
    String doctorName,
    List<TimeSlotDto> slots,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Doctor header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#2E80FA'),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      doctorName.isNotEmpty ? doctorName[0].toUpperCase() : 'D',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 12,
                        color: PdfColor.fromHex('#2E80FA'),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  doctorName,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                    color: PdfColors.white,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  '${slots.length} lich',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('#E5E7EB')),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5), // Ngày
              1: const pw.FlexColumnWidth(1.5), // Thứ
              2: const pw.FlexColumnWidth(1), // Bắt đầu
              3: const pw.FlexColumnWidth(1), // Kết thúc
              4: const pw.FlexColumnWidth(1.2), // Trạng thái
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F9FAFB'),
                ),
                children: [
                  _buildTableHeader('NGAY', fontBold),
                  _buildTableHeader('THU', fontBold),
                  _buildTableHeader('BAT DAU', fontBold),
                  _buildTableHeader('KET THUC', fontBold),
                  _buildTableHeader('TRANG THAI', fontBold),
                ],
              ),
              // Data rows
              ...slots.map((slot) => pw.TableRow(
                    children: [
                      _buildTableCell(_formatDate(slot.date), font),
                      _buildTableCell(_getDayOfWeek(slot.date), font),
                      _buildTableCell(slot.startTime, font),
                      _buildTableCell(slot.endTime, font),
                      _buildStatusCell(slot.status, font, fontBold),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 9,
          color: PdfColor.fromHex('#5F718C'),
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildStatusCell(String status, pw.Font font, pw.Font fontBold) {
    String label;
    String bgColor;
    String textColor;

    switch (status) {
      case 'APPROVED':
        label = 'Da duyet';
        bgColor = '#ECFDF5';
        textColor = '#10B981';
        break;
      case 'REJECTED':
        label = 'Tu choi';
        bgColor = '#FEF2F2';
        textColor = '#EF4444';
        break;
      case 'PENDING':
      default:
        label = 'Cho duyet';
        bgColor = '#FFFBEB';
        textColor = '#F59E0B';
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex(bgColor),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 9,
            color: PdfColor.fromHex(textColor),
          ),
        ),
      ),
    );
  }

  static String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  static String _getDayOfWeek(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        // Map weekday to Vietnamese (without diacritics for PDF)
        final weekdays = ['Thu Hai', 'Thu Ba', 'Thu Tu', 'Thu Nam', 'Thu Sau', 'Thu Bay', 'Chu Nhat'];
        return weekdays[dt.weekday - 1];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
