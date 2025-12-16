import 'package:flutter/material.dart';
import 'package:midtrans_snap/models.dart';

class PayStatusPage extends StatelessWidget {
  final MidtransResponse midTransResponse;
  final String snapToken;
  const PayStatusPage({super.key, required this.midTransResponse, required this.snapToken});

  Color getColor() {
    switch (midTransResponse.transactionStatus.toLowerCase()) {
      case 'settlement':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      case 'cancel':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  IconData getIcon() {
    switch (midTransResponse.transactionStatus.toLowerCase()) {
      case 'settlement':
        return Icons.check;
      case 'pending':
        return Icons.hourglass_empty;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.watch_later;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Status'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getColor().withOpacity(.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  midTransResponse.transactionStatus.toUpperCase(), 
                  style: TextStyle(fontWeight: FontWeight.bold),),
                // Text('Rp ${midTransResponse.grossAmount}'),
                Icon(getIcon(), size: 50, color: getColor(),)
              ],
            ),
          )
        ],
      ),
    );
  }
}