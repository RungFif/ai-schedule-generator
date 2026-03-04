import 'package:flutter/material.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:ai_schedule_generator/services/gemini_service.dart'; // Service untuk memanggil AI
import './schedule_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Menyimpan daftar tugas dalam bentuk List of Map
  final List<Map<String, dynamic>> tasks = [];
  // Controller untuk mengambil input dari TextField
  final TextEditingController taskController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? priority; // Menyimpan nilai dropdown
  bool isLoading = false; // Status loading saat proses AI berjalan

  @override
  void dispose() {
    // Controller harus dibersihkan agar tidak memory leak
    taskController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _addTask() {
    // Validasi sederhana: semua field harus terisi
    if (taskController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        priority != null) {
      setState(() {
        // Tambahkan data ke list
        tasks.add({
          "name": taskController.text,
          "priority": priority!,
          "duration": int.tryParse(durationController.text) ?? 30,
        });
      });
      // Reset form setelah input berhasil
      taskController.clear();
      durationController.clear();
      setState(() => priority = null);
    }
  }

  void _generateSchedule() async {
    // Jika belum ada tugas, tampilkan peringatan
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠ Harap tambahkan tugas dulu!")),
      );
      return;
    }
    setState(() => isLoading = true); // Aktifkan loading
    try {
      // Proses asynchronous ke AI service
      String schedule = await GeminiService.generateSchedule(tasks);
      if (!mounted) return; // Pastikan widget masih aktif
      // Navigasi ke halaman hasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleResultScreen(scheduleResult: schedule),
        ),
      );
    } catch (e) {
      // Tampilkan error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      // Loading dimatikan baik sukses maupun gagal
      if (mounted) setState(() => isLoading = false);
    }
  }

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
      appBar: AppBar(
        title: const Text("AI Schedule", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
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
          child: Column(
            children: [
              // FORM INPUT TUGAS
              _buildGlassContainer(
                Column(
                  children: [
                    TextField(
                      controller: taskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nama Tugas",
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.task, color: Color(0xFF00E5FF)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Input durasi
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Durasi (Mnt)",
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.timer, color: Color(0xFF00E5FF)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Dropdown prioritas
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: priority,
                                dropdownColor: const Color(0xFF0A192F),
                                hint: Text("Prioritas", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5FF)),
                                style: const TextStyle(color: Colors.white),
                                items: ["Tinggi", "Sedang", "Rendah"]
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) => setState(() => priority = val),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tombol tambah tugas
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF).withOpacity(0.1),
                          foregroundColor: const Color(0xFF00E5FF),
                          side: BorderSide(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addTask,
                        icon: const Icon(Icons.add),
                        label: const Text("Tambah ke Daftar", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
              ),
              // LIST TUGAS
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada tugas.\nTambahkan tugas di atas!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            key: Key(task['name'] + index.toString()),
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2A55).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => setState(() => tasks.removeAt(index)),
                            child: _buildGlassContainer(
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _getColor(task['priority']), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getColor(task['priority']).withOpacity(0.4),
                                        blurRadius: 8,
                                      )
                                    ]
                                  ),
                                  child: Center(
                                    child: Text(
                                      task['name'][0].toUpperCase(),
                                      style: TextStyle(color: _getColor(task['priority']), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                title: Text(task['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                subtitle: Text(
                                  "${task['duration']} Menit • ${task['priority']}",
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF2A55)),
                                  onPressed: () => setState(() => tasks.removeAt(index)),
                                ),
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(4),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // FAB GENERATE AI
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: isLoading ? null : _generateSchedule,
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF0A192F),
          elevation: 0,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Color(0xFF0A192F), strokeWidth: 3),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(isLoading ? "Memproses..." : "Buat Jadwal AI", style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Color _getColor(String priority) {
    if (priority == "Tinggi") return const Color(0xFFFF2A55);
    if (priority == "Sedang") return const Color(0xFFFFB300);
    return const Color(0xFF00E5FF);
  }
}
