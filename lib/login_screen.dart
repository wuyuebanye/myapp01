import 'package:flutter/material.dart';
import 'auth_service.dart'; // 替换为你的路径

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signIn() async {
    setState(() { _isLoading = true; });
    await _authService.signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    // StreamBuilder 会自动处理页面跳转，我们只需要在 finally 中停止加载动画
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
  
  void _signUp() async {
    setState(() { _isLoading = true; });
    await _authService.signUpWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("登录 / 注册")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: '邮箱')),
            const SizedBox(height: 10),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码')),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _signIn, child: const Text('登录')),
                  ElevatedButton(onPressed: _signUp, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('注册')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}