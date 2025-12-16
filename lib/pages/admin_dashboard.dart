import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController(); // Untuk menampung URL Gambar
  final _stockController = TextEditingController();

  // URL placeholder default jika admin tidak memasukkan gambar
  final String _defaultPlaceholderUrl = 'https://via.placeholder.com/300/FFA855/FFFFFF?text=No+Image';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Tambah Produk
  Future<void> _addProduct(BuildContext context) async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga wajib diisi!')),
      );
      return;
    }

    // Konversi harga dan stok dengan aman
    final double? price = double.tryParse(_priceController.text);
    final int? stock = int.tryParse(_stockController.text);

    if (price == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga harus berupa angka yang valid!')),
      );
      return;
    }

    try {
      await _firestore.collection('products').add({
        'name': _nameController.text,
        'price': price,
        'description': _descController.text,
        // Pastikan URL selalu ada, menggunakan placeholder jika input kosong
        'imageUrl': _imageController.text.isEmpty
            ? _defaultPlaceholderUrl
            : _imageController.text,
        'stock': stock ?? 0, // Default stok 0 jika input kosong
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Edit Produk
  Future<void> _editProduct(String docId, BuildContext context) async {
    // Konversi harga dan stok dengan aman
    final double? price = double.tryParse(_priceController.text);
    final int? stock = int.tryParse(_stockController.text);

    if (price == null || stock == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga atau Stok harus berupa angka yang valid!')),
      );
      return;
    }

    try {
      await _firestore.collection('products').doc(docId).update({
        'name': _nameController.text,
        'price': price,
        'description': _descController.text,
        // Pastikan URL selalu ada, menggunakan placeholder jika input kosong
        'imageUrl': _imageController.text.isEmpty
            ? _defaultPlaceholderUrl
            : _imageController.text,
        'stock': stock,
      });

      _clearForm();
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diupdate!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Hapus Produk
  Future<void> _deleteProduct(String docId, BuildContext context) async {
    try {
      await _firestore.collection('products').doc(docId).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _descController.clear();
    _imageController.clear();
    _stockController.clear();
  }

  void _showFormDialog({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _descController.text = data['description'] ?? '';
      _imageController.text = data['imageUrl'] ?? '';
      _stockController.text = (data['stock'] ?? 0).toString();
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? 'Tambah Produk Baru' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk *'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga * (mis: 15000)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              // Input URL Gambar
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar Produk',
                  hintText: 'Cth: https://i.imgur.com/example.png',
                ),
              ),
              // Contoh Tombol Simulasi Upload (opsional)
              // Note: Implementasi penuh memerlukan paket file_picker & firebase_storage
              TextButton.icon(
                onPressed: () {
                  // Di sini seharusnya ada logika untuk membuka gallery/camera,
                  // lalu upload ke Firebase Storage, dan
                  // hasil URL-nya dimasukkan ke _imageController.text
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Upload File memerlukan Firebase Storage.')),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Simulasi Upload (Input URL Manual)'),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                _addProduct(context);
              } else {
                _editProduct(docId, context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFFFFA855),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Belum ada produk. Tambahkan produk pertama!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      // Menggunakan URL dari Firestore, jika kosong pakai placeholder
                      data['imageUrl'] ?? _defaultPlaceholderUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rp ${data['price']?.toStringAsFixed(0) ?? '0'}'),
                      Text('Stok: ${data['stock'] ?? 0}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(
                          docId: doc.id,
                          data: data,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus Produk?'),
                              content: const Text('Produk akan dihapus permanen.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteProduct(doc.id, context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFFFFA855),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}