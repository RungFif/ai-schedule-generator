import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:flutter/services.dart'; // Untuk fitur copy ke clipboard
import 'package:flutter_markdown/flutter_markdown.dart'; // Untuk render Markdown
import '../services/calendar_service.dart';

class ScheduleResultScreen extends StatelessWidget {
  final String scheduleResult; // Data hasil dari AI
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  // HELPER FOR GLASSMORPHISM
  Widget _buildGlassContainer(Widget child, {EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.02),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // APP BAR + COPY BUTTON
      appBar: AppBar(
        title: const Text("Hasil Jadwal Optimal", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF00E5FF)),
            tooltip: "Salin Jadwal",
            onPressed: () {
              // Menyalin seluruh hasil ke clipboard
              Clipboard.setData(ClipboardData(text: scheduleResult));
              // Notifikasi kecil ke user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Jadwal berhasil disalin!", style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF0A192F)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A192F), Color(0xFF020C1B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // HEADER INFORMASI
                _buildGlassContainer(
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, color: Color(0xFF00E5FF)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Jadwal ini disusun otomatis oleh AI berdasarkan prioritas Anda.",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                const SizedBox(height: 15),
                // AREA HASIL (MARKDOWN)
                Expanded(
                  child: _buildGlassContainer(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Markdown(
                        data: scheduleResult, // Data dari AI
                        selectable: true, // Bisa copy sebagian teks
                        padding: const EdgeInsets.all(16),
                        // Styling agar tampilan lebih profesional
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          // Styling heading
                          h1: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E5FF),
                          ),
                          h2: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          h3: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00E5FF),
                          ),
                          listBullet: const TextStyle(color: Color(0xFF00E5FF)),
                          // Styling tabel
                          tableBorder: TableBorder.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          tableHeadAlign: TextAlign.center,
                          tablePadding: const EdgeInsets.all(8),
                          tableCellsDecoration: const BoxDecoration(),
                        ),
                        // Custom builder (opsional/advanced)
                        builders: {'table': TableBuilder()},
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
                const SizedBox(height: 15),
                // TOMBOL TAMBAH KE KALENDER
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: const Color(0xFF0A192F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                    ),
                    onPressed: () async {
                      try {
                        await CalendarService.openScheduleInGoogleCalendar(
                          scheduleResult,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal membuka kalender: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                        );
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Tambahkan ke Google Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                // TOMBOL KEMBALI
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Buat Jadwal Baru"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    dynamic element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // Menggunakan render default (tidak diubah)
    return null;
  }
}
