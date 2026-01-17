import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donasi_model.dart';
import '../providers/donasi_provider.dart';

class FormDonasiScreen extends StatefulWidget {
  final Function(Donasi)? onDonasiCreated;
  final Donasi? donasiEdit;

  const FormDonasiScreen({
    Key? key,
    this.onDonasiCreated,
    this.donasiEdit,
  }) : super(key: key);

  @override
  State<FormDonasiScreen> createState() => _FormDonasiScreenState();
}

class _FormDonasiScreenState extends State<FormDonasiScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TextEditingController _targetController;
  late TextEditingController _namaController;
  late TextEditingController _nimController;
  late TextEditingController _universitasController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _rekeningController;

  String? _selectedKategori;
  DateTime? _selectedDeadline;

  final List<String> _kategoriList = [
    'Biaya Kuliah',
    'Tugas Akhir / Skripsi',
    'Kebutuhan Kuliah (Laptop, Buku)',
    'Kompetisi / Lomba',
    'Magang / Internship',
    'Kegiatan Organisasi',
  ];

  @override
  void initState() {
    super.initState();

    //  INISIALISASI: Jika mode edit, isi dengan data lama
    final isEditMode = widget.donasiEdit != null;

    _judulController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.judul : '',
    );
    _deskripsiController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.deskripsi : '',
    );
    _targetController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.target.toString() : '',
    );
    _namaController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.namaMahasiswa : '',
    );
    _nimController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.nim : '',
    );
    _universitasController = TextEditingController(
      text: isEditMode ? widget.donasiEdit!.universitas : '',
    );
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _rekeningController = TextEditingController(text: '');

    //  Set kategori jika edit (mapping ke format dropdown)
    if (isEditMode) {
      _selectedKategori = _mapKategoriToDropdown(widget.donasiEdit!.kategori);

      // Set deadline berdasarkan sisaHari
      _selectedDeadline = DateTime.now().add(
        Duration(days: widget.donasiEdit!.sisaHari),
      );
    }
  }

  //  Helper: Mapping kategori dari model ke dropdown
  String _mapKategoriToDropdown(String kategori) {
    switch (kategori) {
      case 'Tugas Akhir':
        return 'Tugas Akhir / Skripsi';
      case 'Kebutuhan Kuliah':
        return 'Kebutuhan Kuliah (Laptop, Buku)';
      case 'Kompetisi':
        return 'Kompetisi / Lomba';
      case 'Magang':
        return 'Magang / Internship';
      case 'Organisasi':
        return 'Kegiatan Organisasi';
      default:
        return kategori;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _targetController.dispose();
    _namaController.dispose();
    _nimController.dispose();
    _universitasController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rekeningController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedKategori == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori donasi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih batas waktu donasi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = Provider.of<DonasiProvider>(context, listen: false);
      final isEditMode = widget.donasiEdit != null;

      // Hitung sisa hari
      final sisaHari = _selectedDeadline!.difference(DateTime.now()).inDays;

      // Mapping kategori
      String kategoriMapped = _selectedKategori!;
      if (_selectedKategori == 'Tugas Akhir / Skripsi') {
        kategoriMapped = 'Tugas Akhir';
      } else if (_selectedKategori == 'Kebutuhan Kuliah (Laptop, Buku)') {
        kategoriMapped = 'Kebutuhan Kuliah';
      } else if (_selectedKategori == 'Kompetisi / Lomba') {
        kategoriMapped = 'Kompetisi';
      } else if (_selectedKategori == 'Magang / Internship') {
        kategoriMapped = 'Magang';
      } else if (_selectedKategori == 'Kegiatan Organisasi') {
        kategoriMapped = 'Organisasi';
      }

      if (isEditMode) {
        //  MODE EDIT: Update donasi yang sudah ada
        final donasiUpdate = Donasi(
          id: widget.donasiEdit!.id,
          judul: _judulController.text,
          kategori: kategoriMapped,
          terkumpul: widget.donasiEdit!.terkumpul,
          target: double.parse(_targetController.text),
          jumlahDonatur: widget.donasiEdit!.jumlahDonatur,
          sisaHari: sisaHari,
          namaMahasiswa: _namaController.text,
          nim: _nimController.text,
          universitas: _universitasController.text,
          deskripsi: _deskripsiController.text,
          daftarDonatur: widget.donasiEdit!.daftarDonatur,
          userId: widget.donasiEdit!.userId,
        );

        provider.updateDonasi(donasiUpdate);

        print('\n EDIT MODE - Donasi berhasil diupdate!');
        print('   ID: ${donasiUpdate.id}');
        print('   Judul: ${donasiUpdate.judul}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Donasi berhasil diupdate'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        //  MODE BUAT BARU: Tambah donasi baru
        final newDonasi = Donasi(
          id: DateTime.now().millisecondsSinceEpoch,
          judul: _judulController.text,
          kategori: kategoriMapped,
          terkumpul: 0,
          target: double.parse(_targetController.text),
          jumlahDonatur: 0,
          sisaHari: sisaHari,
          namaMahasiswa: _namaController.text,
          nim: _nimController.text,
          universitas: _universitasController.text,
          deskripsi: _deskripsiController.text,
          daftarDonatur: [],
          userId: provider.currentUserId,
        );

        print('\n CREATE MODE - Donasi baru dibuat!');
        print('   ID: ${newDonasi.id}');
        print('   Judul: ${newDonasi.judul}');
        print('   User ID: ${newDonasi.userId}');

        // Gunakan provider untuk menambah donasi
        provider.tambahDonasi(newDonasi);

        // Legacy callback support (jika ada)
        if (widget.onDonasiCreated != null) {
          widget.onDonasiCreated!(newDonasi);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Donasi berhasil dibuat'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // Kembali ke screen sebelumnya
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.donasiEdit != null;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Edit Donasi' : 'Buat Donasi',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEditMode ? 'Perbarui informasi donasi' : 'Galang dana pendidikan',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informasi Donasi Section
            _buildSectionCard(
              title: 'Informasi Donasi',
              icon: Icons.campaign,
              iconColor: const Color(0xFF4F46E5),
              children: [
                _buildTextField(
                  controller: _judulController,
                  label: 'Judul Donasi',
                  hint: 'Contoh: Dana Kuliah Semester 6 - Teknik Informatika',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul donasi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _targetController,
                  label: 'Target Dana (Rp)',
                  hint: '15000000',
                  icon: Icons.payments,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Target dana harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi & Alasan',
                  hint: 'Ceritakan kondisi dan alasan membutuhkan bantuan dana...',
                  icon: Icons.description,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi harus diisi';
                    }
                    if (value.length < 50) {
                      return 'Deskripsi minimal 50 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data Mahasiswa Section
            _buildSectionCard(
              title: 'Data Mahasiswa',
              icon: Icons.person,
              iconColor: const Color(0xFF7C3AED),
              children: [
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Lengkap',
                  hint: 'Nama lengkap sesuai KTM',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama lengkap harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nimController,
                  label: 'NIM (Nomor Induk Mahasiswa)',
                  hint: '21120119001',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIM harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _universitasController,
                  label: 'Universitas',
                  hint: 'Nama Universitas',
                  icon: Icons.school,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Universitas harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Mahasiswa',
                  hint: 'email@student.ac.id',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'No. WhatsApp',
                  hint: '08123456789',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor WhatsApp harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _rekeningController,
                  label: 'Nomor Rekening',
                  hint: '1234567890 (BCA/BNI/Mandiri)',
                  icon: Icons.account_balance,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor rekening harus diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditMode ? 'Update Donasi' : 'Buat Donasi Sekarang',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedKategori,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: Text(
              'Pilih Kategori',
              style: TextStyle(color: Colors.grey[400]),
              overflow: TextOverflow.ellipsis,
            ),
            items: _kategoriList.map((String kategori) {
              return DropdownMenuItem<String>(
                value: kategori,
                child: Text(
                  kategori,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedKategori = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Batas Waktu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  _selectedDeadline == null
                      ? 'Pilih batas waktu'
                      : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}',
                  style: TextStyle(
                    color: _selectedDeadline == null
                        ? Colors.grey[400]
                        : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}