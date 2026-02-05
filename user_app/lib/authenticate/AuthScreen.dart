import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/HomePage.dart';
import 'package:user_app/global.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool isSignIn = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Only for Sign Up

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Colors
  final Color primaryColor = Color(0xFFff6b6b);
  final Color primaryDarkColor = Color(0xFFe65555);
  final Color secondaryColor = Color(0xFFffa500);
  final Color backgroundColor = Color(0xFFf8f5f5);
  final Color darkBackgroundColor = Color(0xFF230f0f);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isSignIn = !isSignIn;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (isSignIn) {
        // SIGN IN LOGIC
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Fetch user data to update global currentUser
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          currentUser = querySnapshot.docs.first.get('name');
          uid = querySnapshot.docs.first.id;
        } else {
          // User exists in Auth but not in Firestore - create document
          final User? user = userCredential.user;
          if (user != null) {
            final docRef = await FirebaseFirestore.instance.collection('users').add({
              "email": user.email,
              "orders": [],
              "name": user.displayName ?? user.email?.split('@')[0] ?? 'User',
            });
            currentUser = user.displayName ?? user.email?.split('@')[0] ?? 'User';
            uid = docRef.id;
          }
        }

        if (userCredential.user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }

      } else {
        // SIGN UP LOGIC
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User? user = userCredential.user;
        if (user != null) {
          // Update display name
          await user.updateDisplayName(_nameController.text.trim());
          
          currentUser = _nameController.text.trim();
          
          // Create user record in Firestore
          final docRef = await FirebaseFirestore.instance.collection('users').add({
            "email": user.email,
            "orders": [],
            "name": _nameController.text.trim(),
          });
          
          uid = docRef.id;

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        currentUser = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        
        // Check if user already exists in Firestore to prevent duplicates
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          // User exists, just get the uid
          uid = querySnapshot.docs.first.id;
        } else {
          // Create new user document only if doesn't exist
          final docRef = await FirebaseFirestore.instance.collection('users').add({
            "email": user.email,
            "orders": [],
            "name": user.displayName ?? user.email?.split('@')[0] ?? 'User',
          });
          uid = docRef.id;
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      if (mounted) {
        _showErrorDialog("Google Sign In failed. Please try again.");
      }
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
    final Size size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.40;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        height: size.height,
        width: double.infinity,
        child: Stack(
          children: [
            // Top Gradient Section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFFff8e53), secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative patterns
                    Positioned(
                      top: 40,
                      left: 40,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                        ),
                        transform: Matrix4.rotationZ(0.2),
                      ),
                    ),
                     Positioned(
                      bottom: 80,
                      right: 40,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 4), // dashed simulated by transparency
                        ),
                      ),
                    ),
                     Positioned(
                      top: size.height * 0.1,
                      right: size.width * 0.25,
                      child: Transform.rotate(
                        angle: 0.785, // 45 deg
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Logo and Title
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(Icons.restaurant_menu, color: Colors.white, size: 32),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Apna Canteen",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                            ),
                          ),
                           Text(
                            "Skip the queue, enjoy the food",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Auth Card
            Positioned(
              top: headerHeight - 30, // Overlap
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 40,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      // Tabs
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (!isSignIn) _toggleAuthMode();
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSignIn ? primaryColor : Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    height: 2,
                                    color: isSignIn ? primaryColor : Colors.transparent,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (isSignIn) _toggleAuthMode();
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: !isSignIn ? primaryColor : Colors.grey[400],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    height: 2,
                                    color: !isSignIn ? primaryColor : Colors.transparent,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isSignIn) ...[
                              Text("Full Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[900])),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[50], // gray-50
                                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                                  hintText: "John Doe",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                   focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                validator: (value) {
                                  if (!isSignIn && (value == null || value.isEmpty)) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                            ],

                            Text("Email Address", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[900])),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[400]),
                                hintText: "student@university.edu",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[900])),
                                // if (isSignIn)
                                //   InkWell(
                                //     onTap: () {},
                                //     child: Text("Forgot Password?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                                //   )
                              ],
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                hintText: "••••••••",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            if (isSignIn) ...[
                              SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text("Forgot Password?", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                                ),
                              )
                            ],

                            SizedBox(height: 24),

                            // Submit Button
                            Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, Color(0xFFff8e53)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitAuthForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading 
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        isSignIn ? "SIGN IN" : "SIGN UP",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[200])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Or continue with",
                              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[200])),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Google Button
                       Container(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: Icon(FontAwesomeIcons.google, color: Colors.red, size: 20),
                          label: Text(
                            "Google",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[200]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSignIn ? "Don't have an account? " : "Already have an account? ",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          InkWell(
                            onTap: _toggleAuthMode,
                            child: Text(
                              isSignIn ? "Sign Up" : "Sign In",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
