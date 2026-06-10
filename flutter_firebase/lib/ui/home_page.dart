import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/core/services/auth_service.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  String? _token;
  bool _loading = false;
  final _serverKeyController = TextEditingController();
  final _targetTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final t = await FirebaseMessaging.instance.getToken();
    if (!mounted) return;
    setState(() => _token = t);
  }

  Future<void> _signOut() async {
    await _auth.logout();
  }

  Future<void> _subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('news');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribed to topic: news')));
  }

  Future<void> _unsubscribeTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('news');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unsubscribed from topic: news')));
  }

  Future<void> _sendTestNotificationViaServer() async {
    final serverKey = _serverKeyController.text.trim();
    final target = _targetTokenController.text.trim();
    if (serverKey.isEmpty || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide server key and target token')));
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final body = {
      'to': target,
      'notification': {'title': 'Test', 'body': 'This is a test notification from app'},
    };

    final res = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey'
    }, body: jsonEncode(body));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status: ${res.statusCode}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged in as: ${widget.user.email ?? widget.user.uid}'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _signOut, child: const Text('Sign out')),
            const Divider(),
            const Text('FCM Token:'),
            SelectableText(_token ?? 'Loading...'),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: _loadToken, child: const Text('Refresh token')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _token == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _token ?? ''));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token copied')));
                      },
                child: const Text('Copy token'),
              )
            ]),
            const Divider(),
            Row(children: [
              ElevatedButton(onPressed: _subscribeTopic, child: const Text('Subscribe topic')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _unsubscribeTopic, child: const Text('Unsubscribe')),
            ]),
            const SizedBox(height: 16),
            const Text('Send test (requires Server Key)'),
            TextField(controller: _serverKeyController, decoration: const InputDecoration(labelText: 'Server Key')),
            TextField(controller: _targetTokenController, decoration: const InputDecoration(labelText: 'Target FCM token')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loading ? null : _sendTestNotificationViaServer, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send test notification')),
            const SizedBox(height: 16),
            const Text('Tip: You can also send notifications from Firebase Console targeting the token or the topic `news`.'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serverKeyController.dispose();
    _targetTokenController.dispose();
    super.dispose();
  }
}
