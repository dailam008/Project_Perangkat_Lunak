import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'keranjang_page.dart';
import 'produk_page.dart';

// ====================================================================
// 1. CUSTOMER SERVICE CHAT PAGE
// ====================================================================
class CustomerServiceChatPage extends StatefulWidget {
  const CustomerServiceChatPage({super.key});

  @override
  State<CustomerServiceChatPage> createState() =>
      _CustomerServiceChatPageState();
}

class _CustomerServiceChatPageState extends State<CustomerServiceChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Data simulasi pesan chat (TELAH DIPERBAIKI: HANYA PESAN SELAMAT DATANG DARI CS)
  final List<Map<String, String>> _messages = [
    {
      "sender": "CS",
      "text":
          "Selamat datang di Layanan Bantuan Biofir. Ada yang bisa kami bantu hari ini? Silakan sampaikan keluhan atau pertanyaan Anda.",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Memastikan scroll ke bawah segera setelah widget dibuat
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi untuk scroll ke pesan terbaru
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

    // Tambahkan pesan pengguna ke daftar
    setState(() {
      _messages.add({"sender": "User", "text": text});
    });

    // Hapus teks dari input setelah dikirim
    _controller.clear();
    _scrollToBottom();

    // Simulasi balasan CS (opsional: tambahkan delay)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Balasan bot yang lebih umum
        _messages.add({
          "sender": "CS",
          "text":
              "Terima kasih atas pesan Anda. Mohon tunggu sebentar, CS kami sedang memproses pertanyaan Anda.",
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold di wrap dengan SafeArea agar chat tidak tertutup notch atau area aman lainnya
    return Scaffold(
      appBar: AppBar(
        title: const Text("CS Chat (Layanan Bantuan)"),
        backgroundColor: const Color(0xFFFFA855),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Daftar Pesan
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              // Pesan baru muncul di bawah
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'User';
                return _buildMessageBubble(message['text']!, isUser);
              },
            ),
          ),
          // Input Teks
          const Divider(height: 1.0),
          Container(
            // Padding bawah untuk menangani keyboard yang muncul
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
        // Batas maksimal lebar bubble chat
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFFA855) : const Color(0xFFFCE9DD),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            // Sudut lancip di sisi pengirim
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 13), // Opacity 0.05
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
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
        border: Border.all(color: const Color(0xFFFFA855), width: 1.5),
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
              // Tambahkan warna latar belakang untuk tombol kirim
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
// 2. USER DASHBOARD
// ====================================================================
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    // Menggunakan LaunchMode.externalApplication untuk membuka link di browser/aplikasi eksternal
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Jika gagal meluncurkan URL (walaupun jarang terjadi)
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // BUBBLE KERANJANG
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
            colors: [Color(0xFFFFA855), Color(0xFFFCE9DD), Colors.white],
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
                  // HEADER
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
                          onPressed: () {
                            // Aksi untuk profil
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // MENU GRID
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
                          // NAVIGASI KE PRODUK PAGE
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProdukPage(),
                            ),
                          );
                        },
                      ),
                      // NAVIGASI KE CHAT IN-APP BARU
                      _buildMenuItem(
                        icon: Icons.support_agent_outlined,
                        label: "CS Chat",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerServiceChatPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.people_outline,
                        label: "Testimoni",
                        onTap: () {
                          // Aksi untuk Testimoni
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.card_membership_outlined,
                        label: "Membership",
                        onTap: () {
                          // Aksi untuk Membership
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ARTIKEL
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

                  // TIPS KESEHATAN
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

                  // BERITA TERKINI
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
                            title:
                                "Kalung Biofir Makin Diminati Warga Pekanbaru",
                            url:
                                "https://www.riauinfo.com/kalung-biofir-makin-diminati-warga-pekanbaru/",
                          ),
                          const SizedBox(width: 15),

                          _buildNewsCard(
                            image: "assets/images/kemasan-Biofir.jpg",
                            title: "Biofir untuk kesehatan & kualitas hidup",
                            url:
                                "https://daengbattala.com/2011/06/22/jaga-kesehatan-dan-kualitas-hidup-dengan-biofir/",
                          ),
                          const SizedBox(width: 15),

                          _buildNewsCard(
                            image: "assets/images/Kalung Biofir Warna.jpg",
                            title: "Kalung Kesehatan Biofir Warna",
                            url:
                                "https://biofirindonesia.blogspot.com/2011/10/kalung-biofir-warna-fancy-color-dan-manfaat.html",
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

  // ARTICLE CARD
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

  // MENU ITEM
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

  // NEWS CARD
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
        margin: const EdgeInsets.only(right: 15),
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
              // Menggunakan Image.asset (pastikan path assets sudah benar di proyek Anda)
              Image.asset(
                image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      "Gagal Load Gambar",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // FIXED OPACITY GRADIENT
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

              // TEXT
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
                      style: TextStyle(fontSize: 11, color: Colors.white70),
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
