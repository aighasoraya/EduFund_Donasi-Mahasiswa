import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Future<String?> signUp({
    required String email,
    required String password,
    required String nama,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String privateKey = _generateRandomKey(32);
      String publicKey = _generatePublicKey(privateKey);

      if (kDebugMode) {
        print("============================================");
        print("       LOG SISTEM KEAMANAN (CRYPTO)         ");
        print("============================================");
        print("ACTION     : GENERATE KEY PAIR (SECURE)");
        print("PRIVATE KEY: $privateKey");
        print("PUBLIC KEY : $publicKey");
        print("============================================");
      }

      await _storage.write(key: 'private_key', value: privateKey);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nama': nama,
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'publicKey': publicKey,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan sistem: $e';
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Login dibatalkan";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          String privateKey = _generateRandomKey(32);
          String publicKey = _generatePublicKey(privateKey);

          await _storage.write(key: 'private_key', value: privateKey);

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'nama': user.displayName ?? "User Google",
            'email': user.email,
            'role': 'mahasiswa',
            'phoneNumber': user.phoneNumber ?? "-",
            'publicKey': publicKey,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          String? existingKey = await _storage.read(key: 'private_key');
          if (existingKey == null) {
            String newKey = _generateRandomKey(32);
            await _storage.write(key: 'private_key', value: newKey);
            await _firestore.collection('users').doc(user.uid).update({
              'publicKey': _generatePublicKey(newKey)
            });
          }
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Gagal Login Google: $e";
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.get('role') ?? 'user';
      }
      return 'user';
    } catch (e) {
      print("Error getting role: $e");
      return 'user';
    }
  }

  String _generateRandomKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _generatePublicKey(String privateKey) {
    try {
      var keyBytes = base64Url.decode(privateKey);
      var digest = sha256.convert(keyBytes);
      return digest.toString();
    } catch (e) {
      var bytes = utf8.encode(privateKey);
      return sha256.convert(bytes).toString();
    }
  }
}