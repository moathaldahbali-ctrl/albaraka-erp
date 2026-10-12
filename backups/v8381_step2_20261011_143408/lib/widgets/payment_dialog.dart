import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentResult {
  final double paidAmount;
  final double changeAmount;
  final String? customerName;
  PaymentResult({
    required this.paidAmount,
    required this.changeAmount,
    this.customerName,
  });
}

class PaymentDialog extends StatefulWidget {
  final double total;
  final String? initialCustomerName;
  const PaymentDialog({
    super.key,
    required this.total,
    this.initialCustomerName,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late final TextEditingController _paidCtrl;
  final _customerCtrl = TextEditingController();

  double get _paid =>
      double.tryParse(_paidCtrl.text.replaceAll(',', '')) ?? 0;
  double get _change =>
      _paid > widget.total ? _paid - widget.total : 0;
  double get _remaining =>
      _paid < widget.total ? widget.total - _paid : 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialCustomerName != null) {
      _customerCtrl.text = widget.initialCustomerName!;
    }
    _paidCtrl = TextEditingController(text: widget.total.toStringAsFixed(0));
    _paidCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paidCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _paidCtrl.text.length,
      );
    });
  }

  @override
  void dispose() {
    _paidCtrl.dispose();
    _customerCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final paid = _paid;
    if (paid <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل المبلغ المدفوع'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      PaymentResult(
        paidAmount: paid,
        changeAmount: _change,
        customerName: _customerCtrl.text.trim().isEmpty
            ? null
            : _customerCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Text(
                      'الدفع',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _label('الصافي'),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFFFFDE7),
                  child: Center(
                    child: Text(
                      widget.total.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _label('المبلغ المدفوع'),
                TextField(
                  controller: _paidCtrl,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirm(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  textAlign: TextAlign.center,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFEF6C00), width: 2),
                        borderRadius: BorderRadius.circular(4)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 10),
                _label('قيمة المردود'),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFFFFDE7),
                  child: Center(
                    child: Text(
                      _change.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _label('المبلغ المتبقي'),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: _remaining > 0
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFC8E6C9),
                  child: Center(
                    child: Text(
                      _remaining.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _remaining > 0
                            ? Colors.red.shade900
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم العميل (اختياري)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _confirm,
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700),
                        child: const Text('تأكيد وحفظ'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
}