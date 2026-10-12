import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// v7.4 - Opening cash dialog.
/// Returns double on confirm, null on cancel.
class OpeningCashDialog extends StatefulWidget {
  const OpeningCashDialog({super.key});

  @override
  State<OpeningCashDialog> createState() => _OpeningCashDialogState();
}

class _OpeningCashDialogState extends State<OpeningCashDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'أدخل المبلغ الافتتاحي');
      return;
    }
    final value = double.tryParse(text);
    if (value == null || value < 0) {
      setState(() => _error = 'قيمة غير صحيحة');
      return;
    }
    Navigator.pop(context, value);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('النقد الافتتاحي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'المبلغ الموجود في الصندوق',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'المبلغ',
                border: const OutlineInputBorder(),
                suffixText: 'YER',
                errorText: _error,
              ),
              onSubmitted: (_) => _confirm(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancel,
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('فتح الوردية'),
          ),
        ],
      ),
    );
  }
}
