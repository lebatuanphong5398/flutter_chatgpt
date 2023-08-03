import 'package:flutter/material.dart';

class CheckAPi extends StatefulWidget {
  const CheckAPi({super.key});

  @override
  State<CheckAPi> createState() => _CheckAPiState();
}

class _CheckAPiState extends State<CheckAPi> {
  bool _isLoading = false;
  bool? _loginSuccess;
  void _performLogin() async {
    setState(() {
      _isLoading = true;
      _loginSuccess = null; // Reset the login status
    });

    // Simulate network request delay
    await Future.delayed(const Duration(seconds: 3));

    // Replace with actual login logic
    _loginSuccess = true; // Simulated result

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Expanded(
        child: Column(
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : _loginSuccess != null
                    ? Text(_loginSuccess!
                        ? 'Đăng nhập thành công'
                        : 'Đăng nhập thất bại')
                    : const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _performLogin,
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
