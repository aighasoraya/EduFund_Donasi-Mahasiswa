import 'package:flutter/foundation.dart';
import '../models/donasi_model.dart';

class DonasiProvider extends ChangeNotifier {
  // ✅ List donasi dengan 4 data dummy + donatur
  final List<Map<String, dynamic>> _daftarDonasiWithDonatur = [
    {
      'donasi': Donasi(
        id: 1,
        judul: 'Dana Kuliah Semester 6 - Teknik Informatika',
        kategori: 'Biaya Kuliah',
        terkumpul: 8500000,
        target: 15000000,
        jumlahDonatur: 42,
        sisaHari: 20,
        namaMahasiswa: 'Ahmad Fauzi',
        nim: '21120119001',
        universitas: 'Universitas Diponegoro',
        deskripsi: 'Membutuhkan bantuan untuk melanjutkan kuliah karena kendala ekonomi keluarga akibat PHK orang tua.',
        daftarDonatur: [],
        userId: 'user_current',
      ),
      'donatur': <Donatur>[
        Donatur(
          nama: 'Budi Santoso',
          jumlah: 500000,
          tanggal: '2024-12-18',
          waktu: '10:30',
          pesan: 'Semangat kuliah!',
        ),
        Donatur(
          nama: 'Alumni TI 2015',
          jumlah: 1000000,
          tanggal: '2024-12-18',
          waktu: '09:15',
          pesan: 'Semoga sukses',
        ),
      ],
    },
    {
      'donasi': Donasi(
        id: 2,
        judul: 'Tugas Akhir: Penelitian IoT untuk Smart City',
        kategori: 'Tugas Akhir',
        terkumpul: 4200000,
        target: 7000000,
        jumlahDonatur: 28,
        sisaHari: 15,
        namaMahasiswa: 'Siti Nurhaliza',
        nim: '21120118045',
        universitas: 'Institut Teknologi Bandung',
        deskripsi: 'Membutuhkan dana untuk penelitian dan pengembangan sistem IoT untuk monitoring lingkungan kota dalam rangka tugas akhir S1.',
        daftarDonatur: [],
        userId: 'user_siti',
      ),
      'donatur': <Donatur>[
        Donatur(
          nama: 'Dr. Bambang',
          jumlah: 1000000,
          tanggal: '2024-12-18',
          waktu: '14:20',
          pesan: 'Untuk kemajuan penelitian',
        ),
        Donatur(
          nama: 'PT Tech Indonesia',
          jumlah: 2000000,
          tanggal: '2024-12-17',
          waktu: '11:30',
          pesan: 'Support untuk inovasi',
        ),
      ],
    },
    {
      'donasi': Donasi(
        id: 3,
        judul: 'Laptop untuk Kuliah Online - Mahasiswa Daerah',
        kategori: 'Kebutuhan Kuliah',
        terkumpul: 6800000,
        target: 8000000,
        jumlahDonatur: 67,
        sisaHari: 10,
        namaMahasiswa: 'Andi Wijaya',
        nim: '21120120078',
        universitas: 'Universitas Hasanuddin',
        deskripsi: 'Laptop rusak dan tidak bisa diperbaiki. Sebagai mahasiswa dari keluarga kurang mampu, kesulitan mengikuti kuliah online.',
        daftarDonatur: [],
        userId: 'user_andi',
      ),
      'donatur': <Donatur>[
        Donatur(
          nama: 'Donatur Peduli',
          jumlah: 500000,
          tanggal: '2024-12-18',
          waktu: '08:00',
          pesan: 'Semoga membantu',
        ),
        Donatur(
          nama: 'Alumni UNHAS',
          jumlah: 1000000,
          tanggal: '2024-12-17',
          waktu: '16:45',
          pesan: 'Tetap semangat!',
        ),
      ],
    },
    {
      'donasi': Donasi(
        id: 4,
        judul: 'Kompetisi Robotika Internasional 2025',
        kategori: 'Kompetisi',
        terkumpul: 12500000,
        target: 20000000,
        jumlahDonatur: 89,
        sisaHari: 25,
        namaMahasiswa: 'Reza Pratama',
        nim: '21120117023',
        universitas: 'Universitas Indonesia',
        deskripsi: 'Tim robotika lolos ke kompetisi internasional di Jepang. Membutuhkan dana untuk transportasi, akomodasi, dan penyempurnaan robot.',
        daftarDonatur: [],
        userId: 'user_reza',
      ),
      'donatur': <Donatur>[
        Donatur(
          nama: 'Himpunan UI',
          jumlah: 3000000,
          tanggal: '2024-12-18',
          waktu: '10:00',
          pesan: 'Bawa nama UI!',
        ),
        Donatur(
          nama: 'PT Robotics Inc',
          jumlah: 5000000,
          tanggal: '2024-12-17',
          waktu: '15:30',
          pesan: 'Sponsor untuk juara',
        ),
      ],
    },
  ];

  // Simulasi user yang login
  String _currentUserId = 'user_current';
  String _currentUserName = 'User Demo';

  List<Map<String, dynamic>> get daftarDonasi => _daftarDonasiWithDonatur;
  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  // Riwayat donasi yang diberikan user
  final List<RiwayatDonasi> _riwayatDonasi = [];
  List<RiwayatDonasi> get riwayatDonasi => _riwayatDonasi;

  // Total donasi yang diberikan
  double get totalDonasiBerikan {
    return _riwayatDonasi.fold(0, (sum, item) => sum + item.jumlah);
  }

  // Method untuk ambil proyek user
  List<Donasi> getProyekUser() {
    return _daftarDonasiWithDonatur
        .where((item) => (item['donasi'] as Donasi).userId == _currentUserId)
        .map((item) => item['donasi'] as Donasi)
        .toList();
  }

  // Ambil donasi dengan donatur berdasarkan ID
  Map<String, dynamic>? ambilDonasiDenganDonatur(int donasiId) {
    try {
      return _daftarDonasiWithDonatur.firstWhere(
            (item) => (item['donasi'] as Donasi).id == donasiId,
      );
    } catch (e) {
      return null;
    }
  }

  // Tambah donasi baru
  void tambahDonasi(Donasi donasiBaru) {
    _daftarDonasiWithDonatur.insert(0, {
      'donasi': donasiBaru,
      'donatur': <Donatur>[],
    });
    notifyListeners();

    if (kDebugMode) {
      print('✅ Donasi berhasil ditambahkan: ${donasiBaru.judul}');
    }
  }

  // Update donasi
  void updateDonasi(Donasi donasiUpdate) {
    final index = _daftarDonasiWithDonatur.indexWhere(
          (item) => (item['donasi'] as Donasi).id == donasiUpdate.id,
    );

    if (index != -1) {
      final donaturLama = _daftarDonasiWithDonatur[index]['donatur'];
      _daftarDonasiWithDonatur[index] = {
        'donasi': donasiUpdate,
        'donatur': donaturLama,
      };
      notifyListeners();

      if (kDebugMode) {
        print('✅ Donasi berhasil diupdate: ${donasiUpdate.judul}');
      }
    }
  }

  // Hapus donasi
  void hapusDonasi(int donasiId) {
    _daftarDonasiWithDonatur.removeWhere(
          (item) => (item['donasi'] as Donasi).id == donasiId,
    );
    notifyListeners();

    if (kDebugMode) {
      print('✅ Donasi berhasil dihapus: ID $donasiId');
    }
  }

  // Berikan donasi
  void berikanDonasi({
    required int donasiId,
    required String namaDonatur,
    required double jumlah,
    String? pesan,
  }) {
    final index = _daftarDonasiWithDonatur.indexWhere(
          (item) => (item['donasi'] as Donasi).id == donasiId,
    );

    if (index != -1) {
      final donasiLama = _daftarDonasiWithDonatur[index]['donasi'] as Donasi;
      final donaturList = _daftarDonasiWithDonatur[index]['donatur'] as List;

      final now = DateTime.now();
      final donaturBaru = Donatur(
        nama: namaDonatur,
        jumlah: jumlah,
        tanggal: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        waktu: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        pesan: pesan,
      );

      // Update donasi
      final donasiUpdate = Donasi(
        id: donasiLama.id,
        judul: donasiLama.judul,
        kategori: donasiLama.kategori,
        terkumpul: donasiLama.terkumpul + jumlah,
        target: donasiLama.target,
        jumlahDonatur: donasiLama.jumlahDonatur + 1,
        sisaHari: donasiLama.sisaHari,
        namaMahasiswa: donasiLama.namaMahasiswa,
        nim: donasiLama.nim,
        universitas: donasiLama.universitas,
        deskripsi: donasiLama.deskripsi,
        daftarDonatur: [...donasiLama.daftarDonatur, donaturBaru],
        userId: donasiLama.userId,
      );

      _daftarDonasiWithDonatur[index] = {
        'donasi': donasiUpdate,
        'donatur': [...donaturList, donaturBaru],
      };

      // Simpan ke riwayat donasi user
      _riwayatDonasi.insert(
        0,
        RiwayatDonasi(
          donasiId: donasiId,
          judulDonasi: donasiLama.judul,
          jumlah: jumlah,
          tanggal: donaturBaru.tanggal,
          waktu: donaturBaru.waktu,
          pesan: pesan,
        ),
      );

      notifyListeners();

      if (kDebugMode) {
        print('✅ Donasi berhasil: $namaDonatur => ${donasiLama.judul}');
        print('   Jumlah: Rp $jumlah');
        print('   Pesan: $pesan');
        print('   Total Riwayat: ${_riwayatDonasi.length}');
      }
    }
  }

  // Tarik dana (hanya untuk pembuat donasi)
  bool tarikDana(int donasiId, double jumlah) {
    final index = _daftarDonasiWithDonatur.indexWhere(
          (item) => (item['donasi'] as Donasi).id == donasiId,
    );

    if (index != -1) {
      final donasiLama = _daftarDonasiWithDonatur[index]['donasi'] as Donasi;

      if (donasiLama.userId != _currentUserId) {
        if (kDebugMode) {
          print('❌ Tidak dapat tarik dana: bukan pemilik donasi');
        }
        return false;
      }

      if (jumlah > donasiLama.terkumpul) {
        if (kDebugMode) {
          print('❌ Tidak dapat tarik dana: jumlah melebihi saldo');
        }
        return false;
      }

      final donasiUpdate = Donasi(
        id: donasiLama.id,
        judul: donasiLama.judul,
        kategori: donasiLama.kategori,
        terkumpul: donasiLama.terkumpul - jumlah,
        target: donasiLama.target,
        jumlahDonatur: donasiLama.jumlahDonatur,
        sisaHari: donasiLama.sisaHari,
        namaMahasiswa: donasiLama.namaMahasiswa,
        nim: donasiLama.nim,
        universitas: donasiLama.universitas,
        deskripsi: donasiLama.deskripsi,
        daftarDonatur: donasiLama.daftarDonatur,
        userId: donasiLama.userId,
      );

      _daftarDonasiWithDonatur[index]['donasi'] = donasiUpdate;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Dana berhasil ditarik: Rp $jumlah');
      }
      return true;
    }
    return false;
  }
}

// Model untuk riwayat donasi
class RiwayatDonasi {
  final int donasiId;
  final String judulDonasi;
  final double jumlah;
  final String tanggal;
  final String waktu;
  final String? pesan;

  RiwayatDonasi({
    required this.donasiId,
    required this.judulDonasi,
    required this.jumlah,
    required this.tanggal,
    required this.waktu,
    this.pesan,
  });
}