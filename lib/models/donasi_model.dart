class Donasi {
  final int id;
  final String judul;
  final String kategori;
  final double terkumpul;
  final double target;
  final int jumlahDonatur;
  final int sisaHari;
  final String namaMahasiswa;
  final String nim;
  final String universitas;
  final String deskripsi;
  final List<Donatur> daftarDonatur;
  final String userId;

  Donasi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.terkumpul,
    required this.target,
    required this.jumlahDonatur,
    required this.sisaHari,
    required this.namaMahasiswa,
    required this.nim,
    required this.universitas,
    required this.deskripsi,
    required this.daftarDonatur,
    required this.userId,
  });

  double get persentase {
    if (target == 0) return 0;
    return (terkumpul / target) * 100;
  }

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

  @override
  String toString() {
    return 'Donasi(id: $id, judul: $judul, kategori: $kategori)';
  }
}

class Donatur {
  final String nama;
  final double jumlah;
  final String tanggal;
  final String waktu;
  final String? pesan;

  Donatur({
    required this.nama,
    required this.jumlah,
    required this.tanggal,
    required this.waktu,
    this.pesan,
  });

  @override
  String toString() {
    return 'Donatur(nama: $nama, jumlah: $jumlah)';
  }
}