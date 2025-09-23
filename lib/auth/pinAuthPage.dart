import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/services/auth_service.dart';

class PinAuthPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool isSetup; // true = ตั้งค่า PIN ใหม่, false = ยืนยัน PIN

  const PinAuthPage({super.key, required this.onSuccess, this.isSetup = false});

  @override
  State<PinAuthPage> createState() => _PinAuthPageState();
}

class _PinAuthPageState extends State<PinAuthPage> {
  String enteredPin = '';
  String confirmPin = '';
  bool isConfirming = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo หรือ Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: kButtonColor, borderRadius: BorderRadius.circular(40)),
                child: const Icon(Icons.lock, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                widget.isSetup ? (isConfirming ? 'ยืนยันรหัส PIN' : 'ตั้งรหัส PIN') : 'ใส่รหัส PIN',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                widget.isSetup
                    ? (isConfirming ? 'ใส่รหัส PIN อีกครั้งเพื่อยืนยัน' : 'ตั้งรหัส PIN 6 หลักเพื่อความปลอดภัย')
                    : 'ใส่รหัส PIN เพื่อเข้าใช้งาน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),

              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final currentPin = isConfirming ? confirmPin : enteredPin;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: index < currentPin.length ? kButtonColor : Colors.grey.shade300),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

              // Number Pad
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      // Empty space
                      return const SizedBox();
                    } else if (index == 10) {
                      // Number 0
                      return _buildNumberButton('0');
                    } else if (index == 11) {
                      // Delete button
                      return _buildDeleteButton();
                    } else {
                      // Numbers 1-9
                      return _buildNumberButton('${index + 1}');
                    }
                  },
                ),
              ),

              // Cancel button (only for setup)
              if (widget.isSetup) TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
        child: Center(child: Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500))),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade100),
        child: const Center(child: Icon(Icons.backspace_outlined, size: 24)),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (isLoading) return;

    setState(() {
      errorMessage = null;
      if (isConfirming) {
        if (confirmPin.length < 6) {
          confirmPin += number;
          if (confirmPin.length == 6) {
            _handlePinComplete();
          }
        }
      } else {
        if (enteredPin.length < 6) {
          enteredPin += number;
          if (enteredPin.length == 6) {
            _handlePinComplete();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    if (isLoading) return;

    setState(() {
      errorMessage = null;
      if (isConfirming) {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        }
      } else {
        if (enteredPin.isNotEmpty) {
          enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        }
      }
    });
  }

  Future<void> _handlePinComplete() async {
    setState(() {
      isLoading = true;
    });

    if (widget.isSetup) {
      if (!isConfirming) {
        // First PIN entry - move to confirmation
        setState(() {
          isConfirming = true;
          isLoading = false;
        });
      } else {
        // Confirming PIN
        if (enteredPin == confirmPin) {
          await _savePinToStorage(enteredPin);
          widget.onSuccess();
        } else {
          setState(() {
            errorMessage = 'รหัส PIN ไม่ตรงกัน กรุณาลองใหม่';
            enteredPin = '';
            confirmPin = '';
            isConfirming = false;
            isLoading = false;
          });
        }
      }
    } else {
      // Verifying existing PIN
      final isValid = await _verifyPin(enteredPin);
      if (isValid) {
        widget.onSuccess();
      } else {
        setState(() {
          errorMessage = 'รหัส PIN ไม่ถูกต้อง';
          enteredPin = '';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _savePinToStorage(String pin) async {
    await AuthService.savePin(pin);
  }

  Future<bool> _verifyPin(String pin) async {
    return await AuthService.verifyPin(pin);
  }
}
