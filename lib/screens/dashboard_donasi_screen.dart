import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'detail_donasi_screen.dart';
import 'form_donasi_screen.dart';
import '../models/donasi_model.dart';
import '../providers/donasi_provider.dart';

class DashboardDonasiScreen extends StatefulWidget {
  const DashboardDonasiScreen({Key? key}) : super(key: key);

  @override
  State<DashboardDonasiScreen> createState() => _DashboardDonasiScreenState();
}

class _DashboardDonasiScreenState extends State<DashboardDonasiScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case 'Biaya Kuliah':
        return const Color(0xFF3B82F6);
      case 'Tugas Akhir':
        return const Color(0xFF8B5CF6);
      case 'Kebutuhan Kuliah':
        return const Color(0xFF10B981);
      case 'Kompetisi':
        return const Color(0xFFF59E0B);
      case 'Magang':
        return const Color(0xFFEC4899);
      case 'Organisasi':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori) {
      case 'Biaya Kuliah':
        return Icons.school;
      case 'Tugas Akhir':
        return Icons.emoji_events;
      case 'Kebutuhan Kuliah':
        return Icons.laptop_mac;
      case 'Kompetisi':
        return Icons.military_tech;
      case 'Magang':
        return Icons.work;
      case 'Organisasi':
        return Icons.groups;
      default:
        return Icons.category;
    }
  }

  void _navigateToDetail(BuildContext context, Donasi donasi, List<Donatur> daftarDonatur) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailDonasiScreen(
          donasi: donasi.copyWith(daftarDonatur: daftarDonatur),
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<DonasiProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Donasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${provider.daftarDonasi.length} Donasi Aktif',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // ✅ BUTTON BUAT DONASI (FLOATING ACTION BUTTON)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormDonasiScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Donasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: Consumer<DonasiProvider>(
        builder: (context, provider, child) {
          final daftarDonasi = provider.daftarDonasi;

          if (daftarDonasi.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarDonasi.length,
              itemBuilder: (context, index) {
                final item = daftarDonasi[index];
                final donasi = item['donasi'] as Donasi;
                final donaturList = item['donatur'] as List;
                final daftarDonatur = donaturList.cast<Donatur>();

                return _buildDonasiCard(context, donasi, daftarDonatur);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDonasiCard(BuildContext context, Donasi donasi, List<Donatur> daftarDonatur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetail(context, donasi, daftarDonatur),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donasi.judul,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getKategoriColor(donasi.kategori)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getKategoriIcon(donasi.kategori),
                                  size: 14,
                                  color: _getKategoriColor(donasi.kategori),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  donasi.kategori,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getKategoriColor(donasi.kategori),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${donasi.namaMahasiswa} • ${donasi.universitas}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Terkumpul',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${donasi.persentase.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: donasi.persentase / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terkumpul',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(donasi.terkumpul),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(donasi.target),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${donasi.jumlahDonatur}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'donatur',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${donasi.sisaHari}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'hari lagi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F46E5).withOpacity(0.1),
                    const Color(0xFF7C3AED).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign,
                size: 64,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Donasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Donasi yang dibuat akan\nmuncul di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension DonasiExtension on Donasi {
  Donasi copyWith({
    int? id,
    String? judul,
    String? kategori,
    double? terkumpul,
    double? target,
    int? jumlahDonatur,
    int? sisaHari,
    String? namaMahasiswa,
    String? nim,
    String? universitas,
    String? deskripsi,
    List<Donatur>? daftarDonatur,
    String? userId,
  }) {
    return Donasi(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      kategori: kategori ?? this.kategori,
      terkumpul: terkumpul ?? this.terkumpul,
      target: target ?? this.target,
      jumlahDonatur: jumlahDonatur ?? this.jumlahDonatur,
      sisaHari: sisaHari ?? this.sisaHari,
      namaMahasiswa: namaMahasiswa ?? this.namaMahasiswa,
      nim: nim ?? this.nim,
      universitas: universitas ?? this.universitas,
      deskripsi: deskripsi ?? this.deskripsi,
      daftarDonatur: daftarDonatur ?? this.daftarDonatur,
      userId: userId ?? this.userId,
    );
  }
}