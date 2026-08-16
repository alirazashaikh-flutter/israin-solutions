import 'package:flutter/material.dart';

class MessageProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
}
