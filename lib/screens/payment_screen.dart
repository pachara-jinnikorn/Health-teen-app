import 'package:flutter/material.dart';
import 'payment_details_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum PaymentMethod { paypal, card, promptpay }

class _PaymentScreenState extends State<PaymentScreen> {
  static const int amountTHB = 600;
  PaymentMethod _method = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // สรุปแพ็กเกจ
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Premium Plan (Monthly)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Unlock all premium features'),
                          ],
                        ),
                      ),
                      Text('฿$amountTHB',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold)),

              RadioListTile<PaymentMethod>(
                value: PaymentMethod.paypal,
                groupValue: _method,
                title: const Text('PayPal'),
                onChanged: (v) => setState(() => _method = v!),
              ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.card,
                groupValue: _method,
                title: const Text('Credit / Debit Card'),
                onChanged: (v) => setState(() => _method = v!),
              ),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.promptpay,
                groupValue: _method,
                title: const Text('PromptPay (TH)'),
                onChanged: (v) => setState(() => _method = v!),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentDetailsScreen(
                          method: _method,
                          amountTHB: amountTHB,
                        ),
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
