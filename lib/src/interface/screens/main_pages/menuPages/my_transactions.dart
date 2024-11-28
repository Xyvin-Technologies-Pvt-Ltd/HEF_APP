// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hef/src/data/models/transaction_model.dart';
// import 'package:intl/intl.dart';
// import 'package:kssia/src/data/globals.dart';
// import 'package:kssia/src/data/models/transaction_model.dart';
// import 'package:kssia/src/data/services/api_routes/transactions_api.dart';
// import 'package:kssia/src/interface/common/loading.dart';

// class MyTransactionsPage extends StatefulWidget {
//   const MyTransactionsPage({Key? key}) : super(key: key);

//   @override
//   _MyTransactionsPageState createState() => _MyTransactionsPageState();
// }

// class _MyTransactionsPageState extends State<MyTransactionsPage> {
//   String selectedStatus = 'All'; // Default selection

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final asyncTransactions = ref.watch(fetchTransactionsProvider);
//         return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               title: const Text(
//                 "My Transactions",
//                 style: TextStyle(fontSize: 17),
//               ),
//               backgroundColor: Colors.white,
//               scrolledUnderElevation: 0,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ),
//             body: asyncTransactions.when(
//               loading: () => const Center(child: LoadingAnimation()),
//               error: (error, stackTrace) {
//                 // Handle error state
//                 return const Center(
//                   child: Text('No Transaction found'),
//                 );
//               },
//               data: (transactions) {
//                 // Filtered lists based on status
//                 final approved = transactions
//                     .where((transaction) => transaction.status == 'accepted')
//                     .toList();
//                 final pending = transactions
//                     .where((transaction) => transaction.status == 'pending')
//                     .toList();
//                 final rejected = transactions
//                     .where((transaction) => transaction.status == 'rejected')
//                     .toList();

//                 // List of transactions to show based on filter
//                 List<Transaction> filteredTransactions;
//                 if (selectedStatus == 'All') {
//                   filteredTransactions = transactions;
//                 } else if (selectedStatus == 'Approved') {
//                   filteredTransactions = approved;
//                 } else if (selectedStatus == 'Pending') {
//                   filteredTransactions = pending;
//                 } else {
//                   filteredTransactions = rejected;
//                 }

//                 return Column(
//                   children: [
//                     // ChoiceChips for filter
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Wrap(
//                         spacing: 8.0,
//                         children: [
//                           _buildChoiceChip('All'),
//                           _buildChoiceChip('Approved'),
//                           _buildChoiceChip('Pending'),
//                           _buildChoiceChip('Rejected'),
//                         ],
//                       ),
//                     ),
//                     // Transaction list
//                     Expanded(
//                       child: _transactionList(filteredTransactions),
//                     ),
//                   ],
//                 );
//               },
//             ));
//       },
//     );
//   }

//   Widget _buildChoiceChip(String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: selectedStatus == label,
//         onSelected: (selected) {
//           setState(() {
//             selectedStatus = label;
//           });
//         },
//         backgroundColor: Colors.white, // Unselected background color
//         selectedColor: const Color(0xFFD3EDCA), // Selected color (light green)
//         shape: RoundedRectangleBorder(
//           side: const BorderSide(color: Color.fromARGB(255, 214, 210, 210)),
//           borderRadius: BorderRadius.circular(20.0), // Circular border
//         ),
//         showCheckmark: false, // Remove tick icon
//       ),
//     );
//   }

//   Widget _transactionList(List<Transaction> transactions) {
//     if (transactions.isEmpty) {
//       return const Center(
//         child: Text('No Transactions'),
//       );
//     }
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: ListView.builder(
//         itemCount: transactions.length,
//         itemBuilder: (context, index) {
//           final transaction = transactions[index];
//           return _transactionCard(transaction);
//         },
//       ),
//     );
//   }

//   Widget _transactionCard(Transaction transaction) {
//     String formattedDate = '';
//     if (transaction.date != null) {
//       formattedDate =
//           DateFormat('d\'th\' MMMM y, h:mm a').format(transaction.date!);
//     }

//     Color statusColor = transaction.status == 'approved'
//         ? Colors.green
//         : transaction.status == 'pending'
//             ? Colors.orange
//             : Colors.red;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//           border: Border.all(color: const Color.fromARGB(255, 225, 217, 217)),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Transaction ID: ${transaction.id}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Status',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF616161),
//                     ),
//                   ),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: statusColor),
//                     ),
//                     child: Text(
//                       transaction.status?.toUpperCase() ?? '',
//                       style: TextStyle(
//                         color: statusColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               _detailRow('Type', transaction.category ?? ''),
//               if (transaction.date != null)
//                 _detailRow('Date & time', formattedDate),
//               _detailRow('Amount paid',
//                   '${transaction.amount??''}'), // Placeholder for now
//               // if (transaction.status == 'rejected')
//               //   Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       const SizedBox(height: 8),
//               //       const Text(
//               //         'Reason for rejection:',
//               //         style: TextStyle(fontWeight: FontWeight.bold),
//               //       ),
//               //       const Text(
//               //         'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//               //         style: TextStyle(fontSize: 12),
//               //       ),
//               //       const SizedBox(height: 8),
//               //       Center(
//               //         child: ElevatedButton(
//               //           style: ElevatedButton.styleFrom(
//               //             backgroundColor: const Color(0xFF004797),
//               //             foregroundColor: Colors.white,
//               //             shape: RoundedRectangleBorder(
//               //               borderRadius: BorderRadius.circular(5),
//               //             ),
//               //           ),
//               //           onPressed: () {
//               //             // Implement re-upload logic
//               //           },
//               //           child: const Text('RE-UPLOAD'),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF616161),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
