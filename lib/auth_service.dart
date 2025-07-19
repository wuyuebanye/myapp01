import 'package:flutter/material.dart'; // Import material for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class AuthService extends ChangeNotifier { // Extend ChangeNotifier
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取当前用户认证状态的流
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 获取当前用户
  User? get currentUser => _auth.currentUser;

  // 注册
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 注册成功后，自动标记为已登录
      await _markUserAsLoggedIn();
      notifyListeners(); // Notify listeners after state change
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log("注册失败: ${e.message}", name: 'auth_service', level: 900, error: e);
      return null;
    }
  }

  // 登录
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 登录成功后，标记为已登录
      await _markUserAsLoggedIn();
      notifyListeners(); // Notify listeners after state change
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log("登录失败: ${e.message}", name: 'auth_service', level: 900, error: e);
      return null;
    }
  }

  // 登出
  Future<void> signOut() async {
    await _auth.signOut();
    // 登出后，清除登录标记
    await _clearLoginMark();
    notifyListeners(); // Notify listeners after state change
  }

  // === 使用 shared_preferences 辅助持久化 ===

  // 标记为已登录
  Future<void> _markUserAsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  // 清除登录标记
  Future<void> _clearLoginMark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }

  // 检查是否曾登录过（可选，但对于优化启动流程有用）
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}