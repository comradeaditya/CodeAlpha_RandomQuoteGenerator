import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';
import '../services/favourites_service.dart';
import 'favourites_screen.dart';
import 'package:flutter/services.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  final FavouritesService _favouritesService = FavouritesService();
  Quote? _currentQuote;
  bool _isLoading = false;
  bool _isFavourite = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _fetchQuote();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
      _isFavourite = false;
    });
    _animationController.reset();

    final quote = await _quoteService.fetchRandomQuote();
    final isFav = await _favouritesService.isFavourite(quote);

    setState(() {
      _currentQuote = quote;
      _isLoading = false;
      _isFavourite = isFav;
    });
    _animationController.forward();
  }

  Future<void> _toggleFavourite() async {
    if (_currentQuote == null) return;
    if (_isFavourite) {
      await _favouritesService.removeFavourite(_currentQuote!);
    } else {
      await _favouritesService.addFavourite(_currentQuote!);
    }
    setState(() => _isFavourite = !_isFavourite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavourite ? 'Added to favourites!' : 'Removed from favourites!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F3460),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyToClipboard() {
    if (_currentQuote == null) return;
    Clipboard.setData(
      ClipboardData(
        text: '"${_currentQuote!.text}" — ${_currentQuote!.author}',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Quote copied to clipboard!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F3460),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareQuote() {
    if (_currentQuote != null) {
      Share.share(
        '"${_currentQuote!.text}"\n\n— ${_currentQuote!.author}',
        subject: 'Inspirational Quote',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Daily Quotes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFFE94560)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavouritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quote Card
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFE94560))
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF16213E), Color(0xFF0F3460)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE94560,
                            ).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            color: Color(0xFFE94560),
                            size: 40,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _currentQuote?.text ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 50,
                            height: 2,
                            color: const Color(0xFFE94560),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '— ${_currentQuote?.author ?? ''}',
                            style: const TextStyle(
                              color: Color(0xFFE94560),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 30),

            // Heart + Share + Copy Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Favourite Button
                GestureDetector(
                  onTap: _toggleFavourite,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isFavourite
                          ? const Color(0xFFE94560).withValues(alpha: 0.2)
                          : const Color(0xFF16213E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE94560),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFE94560),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Share Button
                GestureDetector(
                  onTap: _shareQuote,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Copy Button
                GestureDetector(
                  onTap: _copyToClipboard,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // New Quote Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFFE94560).withValues(alpha: 0.4),
                ),
                child: const Text(
                  'New Quote',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
