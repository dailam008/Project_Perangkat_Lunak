import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'keranjang_page.dart';
import 'produk_page.dart'; // TAMBAHAN IMPORT

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
                          onPressed: () {},
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
                          // TAMBAHAN NAVIGASI KE PRODUK PAGE
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProdukPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.store_outlined,
                        label: "Katalog",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.people_outline,
                        label: "Testimoni",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.card_membership_outlined,
                        label: "Membership",
                        onTap: () {},
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
            color: Colors.black.withValues(alpha: 0.1),
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

  // NEWS CARD (fixed opacity)
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
              color: Colors.black.withValues(alpha: 0.05),
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
              ),

              // FIXED OPACITY GRADIENT
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6), // FIXED
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
