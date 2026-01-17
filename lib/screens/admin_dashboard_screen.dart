import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Wajib untuk Clipboard
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/donasi_provider.dart';
import '../models/donasi_model.dart';
import 'detail_donasi_screen.dart';
import 'login_screen.dart'; // ✅ Import Login Screen
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      final provider = Provider.of<DonasiProvider>(context, listen: false);
      provider.fetchDonasiAdmin();
      provider.fetchRequestPenarikan();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari Admin Dashboard?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: _showLogoutDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.verified_user), text: "Verifikasi"),
            Tab(icon: Icon(Icons.payments), text: "Pencairan"),
            Tab(icon: Icon(Icons.list_alt), text: "Semua Donasi"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVerifikasiList(),
          _buildRequestPenarikanList(),
          _buildSemuaDonasiList(),
        ],
      ),
    );
  }

  Widget _buildVerifikasiList() {
    return Consumer<DonasiProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.daftarDonasiPending.isEmpty) return _buildEmptyState("Tidak ada donasi pending");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.daftarDonasiPending.length,
          itemBuilder: (context, index) {
            final donasi = provider.daftarDonasiPending[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Menunggu Verifikasi", style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    Text(donasi.judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Oleh: ${donasi.namaMahasiswa} (${donasi.universitas})", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 16),
                    const Text("Dokumen Verifikasi:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildDocChip(Icons.badge, "Lihat KTM", () => _bukaLink(donasi.ktmUrl)),
                        _buildDocChip(Icons.credit_card, "Lihat KTP", () => _bukaLink(donasi.ktpUrl)),
                        _buildDocChip(Icons.description, "Lihat Dokumen", () => _bukaLink(donasi.dokumenUrl)),
                      ],
                    ),
                    const Divider(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _konfirmasiAction(context, "Tolak", () => provider.updateStatusDonasi(donasi.id, 'rejected')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Tolak"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _konfirmasiAction(context, "Setujui", () => provider.updateStatusDonasi(donasi.id, 'approved')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Approve", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDocChip(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestPenarikanList() {
    return Consumer<DonasiProvider>(
      builder: (context, provider, _) {
        if (provider.daftarRequestPenarikan.isEmpty) return _buildEmptyState("Belum ada request penarikan");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.daftarRequestPenarikan.length,
          itemBuilder: (context, index) {
            final request = provider.daftarRequestPenarikan[index];
            bool isSignatureValid = request.digitalSignature.isNotEmpty && request.digitalSignature.contains('.');

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.green, size: 28),
                        const SizedBox(width: 12),
                        Text(_currencyFormat.format(request.jumlah), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Dari Donasi: ${request.judulDonasi}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("Rekening Tujuan: ${request.bankInfo}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),

                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Digital Signature (Keamanan):", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            request.digitalSignature,
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(isSignatureValid ? Icons.lock : Icons.warning, size: 12, color: isSignatureValid ? Colors.green : Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                isSignatureValid ? "Terverifikasi Valid" : "Signature Invalid",
                                style: TextStyle(color: isSignatureValid ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _konfirmasiAction(context, "Transfer Dana", () => provider.approvePenarikan(request.id)),
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        label: const Text("Transfer & Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSemuaDonasiList() {
    return Consumer<DonasiProvider>(
      builder: (context, provider, _) {
        final allDonations = provider.daftarDonasi;

        if (allDonations.isEmpty) return _buildEmptyState("Belum ada donasi aktif");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allDonations.length,
          itemBuilder: (context, index) {
            final donasi = allDonations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                  child: const Icon(Icons.volunteer_activism, color: Color(0xFF4F46E5)),
                ),
                title: Text(donasi.judul, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text("Oleh: ${donasi.namaMahasiswa}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailDonasiScreen(donasi: donasi),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _bukaLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Clipboard.setData(ClipboardData(text: url));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link disalin ke clipboard")));
      }
    } catch (e) {
    }
  }

  void _konfirmasiAction(BuildContext context, String action, Function onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Konfirmasi $action"),
        content: const Text("Apakah Anda yakin ingin melanjutkan tindakan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await onConfirm();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil!"), backgroundColor: Colors.green));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            child: const Text("Ya, Lanjutkan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}