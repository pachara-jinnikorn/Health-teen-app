import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/payment_service.dart';
import 'payment_screen.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({
    super.key,
    required this.method,
    required this.amountTHB,
  });

  final PaymentMethod method;
  final int amountTHB;

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // ------- PayPal -------
  final _paypalEmail = TextEditingController();
  final _paypalName = TextEditingController();

  // ------- Card -------
  final _cardName = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardExp = TextEditingController(); // MM/YY
  final _cardCvv = TextEditingController();

  // ------- PromptPay (mock) -------
  // ใช้ uid+amount ก็ได้ แต่ที่นี่ mock เป็นสตริงคงที่เพื่อเดโม
  String get _promptPayPayload =>
      'PROMPTPAY|INVOICE:${DateTime.now().millisecondsSinceEpoch}|AMT:${widget.amountTHB}';

  String _providerName(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.card:
        return 'credit_card';
      case PaymentMethod.promptpay:
        return 'promptpay';
    }
  }

  Future<void> _submit() async {
    // ไม่เก็บข้อมูลใด ๆ ลงฐานข้อมูล: ตรวจความครบถ้วนเฉพาะฝั่งฟอร์ม
    if (widget.method != PaymentMethod.promptpay) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _loading = true);
    try {
      await PaymentService.instance.createMockPayment(
        amountTHB: widget.amountTHB,
        currency: 'THB',
        provider: _providerName(widget.method),
        days: 30,
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Payment Success 🎉'),
          content: Text(
              '฿${widget.amountTHB} THB via ${_providerName(widget.method)}'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.popUntil(context, (r) => r.isFirst); // กลับไปหน้าแรก/โปรไฟล์
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You are now a Premium Member 🎉'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Payment failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _paypalForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _paypalEmail,
            decoration: const InputDecoration(labelText: 'PayPal Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _paypalName,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _cardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardName,
            decoration: const InputDecoration(labelText: 'Name on Card'),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardNumber,
            decoration: const InputDecoration(labelText: 'Card Number'),
            keyboardType: TextInputType.number,
            maxLength: 19,
            validator: (v) => (v == null || v.replaceAll(' ', '').length < 12)
                ? 'Invalid card number'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardExp,
                  decoration:
                      const InputDecoration(labelText: 'Expiry (MM/YY)'),
                  keyboardType: TextInputType.datetime,
                  validator: (v) =>
                      (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v))
                          ? 'Invalid date'
                          : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cardCvv,
                  decoration: const InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (v) =>
                      (v == null || v.length < 3) ? 'Invalid CVV' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _promptPaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Scan & Pay with PromptPay',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // QR MOCK – ใช้ payload จำลอง
        Center(
          child: QrImageView(
            data: _promptPayPayload,
            size: 200,
          ),
        ),
        const SizedBox(height: 8),
        Text('Amount: ฿${widget.amountTHB}',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        const Text('หลังสแกนแล้ว ให้กดปุ่ม "ชำระเงินแล้ว" เพื่อยืนยัน'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loading ? null : _submit, // ยืนยันชำระ (mock)
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('ชำระเงินแล้ว'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = () {
      switch (widget.method) {
        case PaymentMethod.paypal:
          return 'PayPal Details';
        case PaymentMethod.card:
          return 'Card Details';
        case PaymentMethod.promptpay:
          return 'PromptPay';
      }
    }();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (widget.method == PaymentMethod.paypal) _paypalForm(),
              if (widget.method == PaymentMethod.card) _cardForm(),
              if (widget.method == PaymentMethod.promptpay) _promptPaySection(),
              const Spacer(),
              if (widget.method != PaymentMethod.promptpay)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Pay Now'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
