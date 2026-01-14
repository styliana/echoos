import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
        return;
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          ...List.generate(15, (index) => const _BackgroundParticle()),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Echoos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    Text(
                      "Connect. Breathe. Heal.",
                      style: TextStyle(
                        color: Colors.tealAccent.withOpacity(0.7),
                        fontSize: 18,
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 2,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Colors.tealAccent, Colors.transparent],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.tealAccent)
                    else
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _signInWithGoogle,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
                                    height: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundParticle extends StatefulWidget {
  const _BackgroundParticle();

  @override
  State<_BackgroundParticle> createState() => _BackgroundParticleState();
}

class _BackgroundParticleState extends State<_BackgroundParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Offset pos;
  late double size;

  @override
  void initState() {
    super.initState();
    pos = Offset(Random().nextDouble() * 400, Random().nextDouble() * 800);
    size = 2 + Random().nextDouble() * 4;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5 + Random().nextInt(5)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Positioned(
        left: pos.dx,
        top: pos.dy - (_ctrl.value * 100),
        child: Opacity(
          opacity: 0.1,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.tealAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}