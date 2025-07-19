import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart'; // 替换为你的路径

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _noteController = TextEditingController();

  // 添加一条笔记
  void _addNote() async {
    if (_noteController.text.isEmpty) return;

    final user = _authService.currentUser;
    if (user == null) return;

    // 将笔记添加到与用户UID关联的集合中
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .add({
      'content': _noteController.text,
      'createdAt': Timestamp.now(),
    });
    
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.email ?? '主页'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // StreamBuilder 会自动处理页面跳转
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 用于显示用户笔记的列表
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user?.uid) // 只获取当前用户的笔记
                  .collection('notes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final notes = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note['content']),
                      subtitle: Text((note['createdAt'] as Timestamp).toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),
          // 用于添加新笔记的输入区域
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: '写点什么...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}