import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'dto/schedule_dto.dart';

class SchedulePdfService {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  
  // Giờ làm việc (giống schedule_screen)
  static const int startHour = 7;
  static const int endHour = 18;

  /// Helper to create color with opacity
  static PdfColor _withOpacity(PdfColor color, double opacity) {
    return PdfColor(color.red, color.green, color.blue, opacity);
  }

  /// Generate and print/preview PDF of doctor's schedule
  static Future<void> printSchedule({
    required List<ScheduleSlotDto> slots,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<DateTime> weekDays,
    String? doctorName,
  }) async {
    final pdf = await _generatePdf(
      slots: slots,
      weekStart: weekStart,
      weekEnd: weekEnd,
      weekDays: weekDays,
      doctorName: doctorName,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'lich_lam_viec_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Generate PDF document
  static Future<pw.Document> _generatePdf({
    required List<ScheduleSlotDto> slots,
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<DateTime> weekDays,
    String? doctorName,
  }) async {
    final pdf = pw.Document();

    // Load font for Vietnamese
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Group slots by date
    final slotsByDate = <String, List<ScheduleSlotDto>>{};
    for (final slot in slots) {
      final dateKey = '${slot.date.year}-${slot.date.month}-${slot.date.day}';
      slotsByDate.putIfAbsent(dateKey, () => []).add(slot);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(
              weekStart: weekStart,
              weekEnd: weekEnd,
              doctorName: doctorName,
              font: font,
              fontBold: fontBold,
            ),
            pw.SizedBox(height: 12),
            
            // Summary
            _buildSummary(slots, font, fontBold),
            pw.SizedBox(height: 12),
            
            // Calendar grid
            pw.Expanded(
              child: _buildCalendarGrid(
                weekDays: weekDays,
                slotsByDate: slotsByDate,
                font: font,
                fontBold: fontBold,
              ),
            ),
            
            // Footer
            pw.SizedBox(height: 8),
            _buildLegend(font, fontBold),
          ],
        ),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader({
    required DateTime weekStart,
    required DateTime weekEnd,
    String? doctorName,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'LICH LAM VIEC BAC SI',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 20,
                color: PdfColor.fromHex('#0C131D'),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Tuan: ${_dateFormat.format(weekStart)} - ${_dateFormat.format(weekEnd)}',
              style: pw.TextStyle(
                font: font,
                fontSize: 11,
                color: PdfColor.fromHex('#5E718D'),
              ),
            ),
            if (doctorName != null)
              pw.Text(
                'Bac si: $doctorName',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  color: PdfColor.fromHex('#5E718D'),
                ),
              ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'MEDIBOOK',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                color: PdfColor.fromHex('#297EFF'),
              ),
            ),
            pw.Text(
              'Ngay in: ${_dateFormat.format(DateTime.now())}',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColor.fromHex('#9CA3AF'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(
    List<ScheduleSlotDto> slots,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final totalSlots = slots.length;
    final bookedSlots = slots.where((s) => s.bookingId != null).length;
    final availableSlots = totalSlots - bookedSlots;
    final pendingSlots = slots.where((s) => s.status == SlotStatus.PENDING).length;
    final approvedSlots = slots.where((s) => s.status == SlotStatus.APPROVED).length;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F7F8'),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tong', totalSlots.toString(), '#297EFF', font, fontBold),
          _buildStatItem('Da dat', bookedSlots.toString(), '#00C853', font, fontBold),
          _buildStatItem('Trong', availableSlots.toString(), '#5E718D', font, fontBold),
          _buildStatItem('Cho duyet', pendingSlots.toString(), '#FFA000', font, fontBold),
          _buildStatItem('Da duyet', approvedSlots.toString(), '#10B981', font, fontBold),
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
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColor.fromHex('#5E718D'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: PdfColor.fromHex(colorHex),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCalendarGrid({
    required List<DateTime> weekDays,
    required Map<String, List<ScheduleSlotDto>> slotsByDate,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    final hours = List.generate(endHour - startHour, (i) => startHour + i);
    final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E6ECF4')),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          // Day headers
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F9FAFB'),
              border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E6ECF4'))),
            ),
            child: pw.Row(
              children: [
                // Time column header
                pw.Container(
                  width: 50,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Center(
                    child: pw.Text(
                      'Gio',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 9,
                        color: PdfColor.fromHex('#5E718D'),
                      ),
                    ),
                  ),
                ),
                // Day columns
                ...List.generate(7, (index) {
                  final day = weekDays[index];
                  final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
                  final isWeekend = index >= 5;

                  return pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: isToday ? PdfColor.fromHex('#EBF5FF') : null,
                        border: pw.Border(left: pw.BorderSide(color: PdfColor.fromHex('#E6ECF4'))),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            dayNames[index],
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: isToday
                                  ? PdfColor.fromHex('#297EFF')
                                  : (isWeekend ? PdfColor.fromHex('#EF4444') : PdfColor.fromHex('#5E718D')),
                            ),
                          ),
                          pw.Text(
                            '${day.day}/${day.month}',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: isToday
                                  ? PdfColor.fromHex('#297EFF')
                                  : (isWeekend ? PdfColor.fromHex('#EF4444') : PdfColor.fromHex('#0C131D')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Hour rows
          pw.Expanded(
            child: pw.Column(
              children: hours.map((hour) {
                return pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Time label
                      pw.Container(
                        width: 50,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(color: PdfColor.fromHex('#F3F4F6')),
                          ),
                        ),
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2),
                          child: pw.Center(
                            child: pw.Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 8,
                                color: PdfColor.fromHex('#9CA3AF'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Day cells
                      ...List.generate(7, (dayIndex) {
                        final day = weekDays[dayIndex];
                        final dateKey = '${day.year}-${day.month}-${day.day}';
                        final daySlots = slotsByDate[dateKey] ?? [];
                        
                        // Find slots that overlap with this hour
                        final slotsInHour = daySlots.where((slot) {
                          final slotStartHour = slot.startMinutes ~/ 60;
                          final slotEndHour = (slot.endMinutes - 1) ~/ 60;
                          return hour >= slotStartHour && hour <= slotEndHour;
                        }).toList();

                        final isToday = day.year == now.year && day.month == now.month && day.day == now.day;

                        return pw.Expanded(
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              color: isToday ? PdfColor.fromHex('#FAFCFF') : null,
                              border: pw.Border(
                                left: pw.BorderSide(color: PdfColor.fromHex('#E6ECF4')),
                                top: pw.BorderSide(color: PdfColor.fromHex('#F3F4F6')),
                              ),
                            ),
                            child: slotsInHour.isNotEmpty
                                ? _buildSlotCell(slotsInHour.first, hour, font, fontBold)
                                : pw.SizedBox(),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSlotCell(
    ScheduleSlotDto slot,
    int currentHour,
    pw.Font font,
    pw.Font fontBold,
  ) {
    // Only show content if this is the starting hour of the slot
    final slotStartHour = slot.startMinutes ~/ 60;
    if (currentHour != slotStartHour) {
      // Show continuation indicator
      final isBooked = slot.bookingId != null;
      final color = isBooked ? '#00C853' : '#297EFF';
      return pw.Container(
        margin: const pw.EdgeInsets.all(1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              width: 3,
              color: PdfColor.fromHex(color),
            ),
            pw.Expanded(
              child: pw.Container(
                color: _withOpacity(PdfColor.fromHex(color), 0.1),
              ),
            ),
          ],
        ),
      );
    }

    final isBooked = slot.bookingId != null;
    final color = isBooked ? '#00C853' : '#297EFF';
    
    return pw.Container(
      margin: const pw.EdgeInsets.all(1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Left color bar
          pw.Container(
            width: 3,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex(color),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(2),
                bottomLeft: pw.Radius.circular(2),
              ),
            ),
          ),
          // Content
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(2),
              decoration: pw.BoxDecoration(
                color: _withOpacity(PdfColor.fromHex(color), 0.1),
                borderRadius: const pw.BorderRadius.only(
                  topRight: pw.Radius.circular(2),
                  bottomRight: pw.Radius.circular(2),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          isBooked ? 'Da dat' : _getStatusText(slot.status),
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 6,
                            color: PdfColor.fromHex(isBooked ? '#00C853' : _getStatusColor(slot.status)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isBooked && slot.patientName != null)
                    pw.Text(
                      slot.patientName!,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 7,
                        color: PdfColor.fromHex('#0C131D'),
                      ),
                      maxLines: 1,
                    ),
                  pw.Text(
                    '${slot.startTime.substring(0, 5)}-${slot.endTime.substring(0, 5)}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 6,
                      color: PdfColor.fromHex('#5E718D'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLegend(pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        _buildLegendItem('Da dat lich', '#00C853', font),
        pw.SizedBox(width: 16),
        _buildLegendItem('Trong (Da duyet)', '#297EFF', font),
        pw.SizedBox(width: 16),
        _buildLegendItem('Cho duyet', '#FFA000', font),
        pw.SizedBox(width: 16),
        _buildLegendItem('Tu choi', '#EF4444', font),
      ],
    );
  }

  static pw.Widget _buildLegendItem(String label, String colorHex, pw.Font font) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          child: pw.Row(
            children: [
              pw.Container(
                width: 3,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex(colorHex),
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(2),
                    bottomLeft: pw.Radius.circular(2),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: _withOpacity(PdfColor.fromHex(colorHex), 0.2),
                    borderRadius: const pw.BorderRadius.only(
                      topRight: pw.Radius.circular(2),
                      bottomRight: pw.Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: PdfColor.fromHex('#5E718D'),
          ),
        ),
      ],
    );
  }

  static String _getStatusText(SlotStatus status) {
    switch (status) {
      case SlotStatus.APPROVED:
        return 'Trong';
      case SlotStatus.PENDING:
        return 'Cho duyet';
      case SlotStatus.REJECTED:
        return 'Tu choi';
    }
  }

  static String _getStatusColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.APPROVED:
        return '#297EFF';
      case SlotStatus.PENDING:
        return '#FFA000';
      case SlotStatus.REJECTED:
        return '#EF4444';
    }
  }
}
