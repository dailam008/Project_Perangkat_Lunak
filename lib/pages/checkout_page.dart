import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatefulWidget {
  final double totalPrice;

  const CheckoutPage({super.key, required this.totalPrice});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Default pilihan pembayaran
  String _paymentMethod = 'Transfer Bank (BCA)';
  bool _isLoading = false;

  final List<String> _paymentOptions = [
    'Transfer Bank (BCA)',
    'Transfer Bank (Mandiri)',
    'Transfer Bank (BRI)',
    'E-Wallet (GoPay)',
    'E-Wallet (OVO)',
    'E-Wallet (Dana)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Ambil snapshot keranjang saat ini untuk disimpan sebagai detail pesanan
      var cartSnapshot = await FirebaseFirestore.instance.collection('keranjang').get();
      List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) => doc.data()).toList();

      if (items.isEmpty) {
        throw Exception("Keranjang kosong saat checkout diproses");
      }

      // 2. Simpan data pesanan ke Firestore koleksi 'orders'
      await FirebaseFirestore.instance.collection('orders').add({
        'customerName': _nameController.text,
        'customerPhone': _phoneController.text,
        'shippingAddress': _addressController.text,
        'paymentMethod': _paymentMethod,
        'totalPrice': widget.totalPrice,
        'items': items, // Menyimpan detail barang yang dibeli
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'Menunggu Pembayaran',
      });

      // 3. Kosongkan Keranjang setelah berhasil order
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      if (!mounted) return;

      // 4. Tampilkan Dialog Sukses & Kembali
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Pesanan Berhasil!"),
          content: const Text("Terima kasih. Pesanan Anda telah diterima dan sedang diproses."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup Dialog
                Navigator.of(context).pop(); // Kembali dari Checkout Page
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses pesanan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFFFFA855),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FORM DATA DIRI ---
              const Text("Informasi Pengiriman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Penerima",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Nomor Telepon / WhatsApp",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Nomor telepon wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Alamat Lengkap Pengiriman",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Alamat wajib diisi" : null,
              ),

              const SizedBox(height: 24),

              // --- PILIHAN PEMBAYARAN ---
              const Text("Metode Pembayaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _paymentMethod,
                    isExpanded: true,
                    items: _paymentOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value.contains('Bank') ? Icons.account_balance : Icons.account_balance_wallet,
                              color: const Color(0xFFFFA855),
                            ),
                            const SizedBox(width: 10),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _paymentMethod = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- RINGKASAN TOTAL ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Tagihan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      "Rp ${widget.totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA855)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- TOMBOL BAYAR ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA855),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Bayar Sekarang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}