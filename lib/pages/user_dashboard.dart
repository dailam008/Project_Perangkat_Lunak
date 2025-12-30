import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'keranjang_page.dart';
import 'produk_page.dart';

// ====================================================================
// 1. TESTIMONI PAGE
// ====================================================================
class TestimoniPage extends StatefulWidget {
  const TestimoniPage({super.key});

  @override
  State<TestimoniPage> createState() => _TestimoniPageState();
}

class _TestimoniPageState extends State<TestimoniPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testimoni Pelanggan"),
        backgroundColor: const Color(0xFFFFA855),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('testimonials')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada testimoni',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['userName'] ?? 'Anonymous',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < (data['rating']?.toDouble() ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        data['review'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTestimoniPage()),
          );
        },
        backgroundColor: const Color(0xFFFFA855),
        icon: const Icon(Icons.add),
        label: const Text('Kirim Testimoni'),
      ),
    );
  }
}

class TambahTestimoniPage extends StatefulWidget {
  const TambahTestimoniPage({super.key});

  @override
  State<TambahTestimoniPage> createState() => _TambahTestimoniPageState();
}

class _TambahTestimoniPageState extends State<TambahTestimoniPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitTestimoni(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('testimonials').add({
        'userName': _nameController.text,
        'rating': _rating,
        'review': _reviewController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testimoni berhasil dikirim!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Testimoni Anda'),
        backgroundColor: const Color(0xFFFFA855),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Bagikan pengalaman Anda!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Anda *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Nama wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1.0;
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Tulis Review Anda *',
                hintText: 'Ceritakan pengalaman Anda...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Review wajib diisi';
                if (value.length < 10) return 'Review minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submitTestimoni(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA855),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'KIRIM TESTIMONI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// 2. CUSTOMER SERVICE CHAT PAGE
// ====================================================================
class CustomerServiceChatPage extends StatefulWidget {
  const CustomerServiceChatPage({super.key});

  @override
  State<CustomerServiceChatPage> createState() => _CustomerServiceChatPageState();
}

class _CustomerServiceChatPageState extends State<CustomerServiceChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      "sender": "CS",
      "text": "Selamat datang di Layanan Bantuan Biofir. Ada yang bisa kami bantu hari ini? Silakan sampaikan keluhan atau pertanyaan Anda.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "User", "text": text});
    });

    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({"sender": "CS", "text": "Terima kasih atas pesan Anda. Mohon tunggu sebentar, CS kami sedang memproses pertanyaan Anda."});
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CS Chat (Layanan Bantuan)"),
        backgroundColor: const Color(0xFFFFA855),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'User';
                return _buildMessageBubble(message['text']!, isUser);
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
            color: isUser ? const Color(0xFFFFA855) : const Color(0xFFFCE9DD),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 13),
                blurRadius: 3,
                offset: const Offset(1, 2),
              ),
            ]
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFA855), width: 1.5)
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: "Ketik pesan Anda...",
                ),
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFFA855),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// 3. MEMBERSHIP PAGE
// ====================================================================
class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  Future<void> _launchWhatsApp(String packageName) async {
    const phoneNumber = '6289618418569';
    final message = 'Halo, saya tertarik dengan Paket $packageName Membership Biofir. Mohon informasi lebih lanjut untuk pembelian dan pembayaran.';
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat meluncurkan $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Biofir"),
        backgroundColor: const Color(0xFFFFA855),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tingkatkan Kebugaran Anda dengan Paket Membership Eksklusif!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _buildMembershipCard(
              context,
              title: "Paket Muscle",
              subtitle: "Kebugaran Dasar & Vitalitas",
              price: "Rp 250.000 / Tahun",
              color: Colors.green.shade700,
              icon: Icons.fitness_center,
              benefits: [
                "Diskon Produk 5% (Berlaku Selamanya)",
                "Garansi Produk Standar (1 Tahun)",
                "Akses ke Tips Kebugaran Mingguan",
                "Newsletter Eksklusif Biofir",
              ],
            ),
            const SizedBox(height: 20),

            _buildMembershipCard(
              context,
              title: "Paket Black",
              subtitle: "Premium Kesehatan & Jangka Panjang",
              price: "Rp 750.000 / Tahun",
              color: Colors.grey.shade900,
              icon: Icons.diamond_outlined,
              benefits: [
                "Diskon Produk 15% (Berlaku Selamanya)",
                "Garansi Produk Diperpanjang (3 Tahun)",
                "Prioritas Layanan CS 24/7",
                "Pre-Order Produk Baru Biofir",
                "Akses ke Webinar Kesehatan Bulanan",
              ],
            ),
            const SizedBox(height: 20),

            _buildMembershipCard(
              context,
              title: "Paket VIP",
              subtitle: "Eksklusif & Dukungan Penuh (Top Tier)",
              price: "Rp 2.000.000 / Tahun",
              color: const Color(0xFFFFA855),
              icon: Icons.workspace_premium,
              isRecommended: true,
              benefits: [
                "Diskon Produk 30% (Berlaku Selamanya)",
                "Garansi Produk SEUMUR HIDUP",
                "Manager CS Pribadi & Dedikasi Cepat",
                "Undangan Acara Eksklusif (Gathering)",
                "Voucher Ulang Tahun Senilai Rp 200.000",
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Pilih paket yang sesuai dengan kebutuhan kesehatan dan kebugaran Anda!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String price,
        required Color color,
        required IconData icon,
        required List<String> benefits,
        bool isRecommended = false,
      }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isRecommended
            ? BorderSide(color: color, width: 4)
            : BorderSide.none,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Icon(icon, size: 40, color: color),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              price,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 15),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(fontSize: 15, height: 1.3),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _launchWhatsApp(title);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "PILIH PAKET",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// 4. USER DASHBOARD
// ====================================================================
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KeranjangPage()),
          );
        },
        backgroundColor: const Color(0xFFFFA855),
        shape: const CircleBorder(),
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFA855),
              Color(0xFFFCE9DD),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.15, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Hi, Pengguna",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person, color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: [
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: "Produk",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProdukPage()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.support_agent_outlined,
                        label: "CS Chat",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomerServiceChatPage()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.people_outline,
                        label: "Testimoni",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TestimoniPage()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.card_membership_outlined,
                        label: "Membership",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MembershipPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Artikel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildArticle(
                    "🌱 Biofir: Teknologi terbaru yang memanfaatkan energi alami FIR "
                        "untuk menjaga kebugaran tubuh sehari-hari.",
                  ),
                  const SizedBox(height: 12),

                  _buildArticle(
                    "💡 Tahukah Anda? Far Infrared (FIR) dapat membantu "
                        "melancarkan aliran darah & meningkatkan vitalitas.",
                  ),
                  const SizedBox(height: 12),

                  _buildArticle(
                    "🔥 Produk Biofir terus dikembangkan untuk kenyamanan "
                        "dan dukungan kesehatan aktivitas harian.",
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Tips Kesehatan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildArticle(
                    "✨ Gunakan gelang/kalung Biofir setiap hari untuk membantu "
                        "menjaga peredaran darah tetap optimal.",
                  ),
                  const SizedBox(height: 12),

                  _buildArticle(
                    "💧 Minum air putih yang cukup agar energi FIR bekerja maksimal.",
                  ),
                  const SizedBox(height: 12),

                  _buildArticle(
                    "🏃 Cocok untuk olahraga — membantu performa tubuh lebih stabil.",
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Berita Terkini",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildNewsCard(
                            image: "assets/images/kalung_bokir.jpg",
                            title: "Kalung Biofir Makin Diminati Warga Pekanbaru",
                            url: "https://www.riauinfo.com/kalung-biofir-makin-diminati-warga-pekanbaru/",
                          ),
                          const SizedBox(width: 15),

                          _buildNewsCard(
                            image: "assets/images/kemasan-Biofir.jpg",
                            title: "Biofir untuk kesehatan & kualitas hidup",
                            url: "https://daengbattala.com/2011/06/22/jaga-kesehatan-dan-kualitas-hidup-dengan-biofir/",
                          ),
                          const SizedBox(width: 15),

                          _buildNewsCard(
                            image: "assets/images/Kalung Biofir Warna.jpg",
                            title: "Kalung Kesehatan Biofir Warna",
                            url: "https://biofirindonesia.blogspot.com/2011/10/kalung-biofir-warna-fancy-color-dan-manfaat.html",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticle(String text) {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 26),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black87,
            ),
        ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFA855), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFFFFA855)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFFFA855),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard({
    required String image,
    required String title,
    required String url,
  }) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Text("Gagal Load Gambar")),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 153),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Swipe untuk lihat berita lainnya",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}