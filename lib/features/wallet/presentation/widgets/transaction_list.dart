import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/extensions/strings_extensions.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/transaction_entity.dart';
import 'package:intl/intl.dart';

// class TransactionList extends StatefulWidget {
//   final List<TransactionEntity> transactions;
//   final VoidCallback onLoadMore;
//   final bool isFetchingMore;

//   const TransactionList({
//     super.key,
//     required this.transactions,
//     required this.onLoadMore,
//     this.isFetchingMore = false,
//   });

//   @override
//   State<TransactionList> createState() => _TransactionListState();
// }

// class _TransactionListState extends State<TransactionList> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !widget.isFetchingMore) {
//       widget.onLoadMore();
//     }
//   }

//   String _formatTransactionAmount(double value) {
//     final formatted = value % 1 == 0
//         ? value.toInt().toString()
//         : value.toString();

//     return '\$$formatted';
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'success':
//       case 'completed':
//         return context.appColors.brand;

//       case 'failed':
//         return context.appColors.error;

//       default:
//         return Colors.orange;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = context.textTheme;
//     final colors = context.appColors;
//     final l10n = AppLocalizations.of(context)!;

//     final items = widget.transactions;

//     if (items.isEmpty) {
//       return Center(
//         child: Text(
//           l10n.no_transactions_found,
//           style: textTheme.bodyMedium?.copyWith(
//             color: colors.textPrimary.withValues(alpha: 0.6),
//           ),
//         ),
//       );
//     }

//     return Scrollbar(
//       controller: _scrollController,
//       thumbVisibility: true,
//       child: ListView.builder(
//         controller: _scrollController,
//         itemCount: items.length + (widget.isFetchingMore ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index == items.length) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
//               child: Center(
//                 child: SizedBox(
//                   height: 24,
//                   width: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2.5),
//                 ),
//               ),
//             );
//           }
//           final trx = items[index];
//           final isRewardedSource =
//               trx.balanceSource?.toLowerCase() == 'rewarded' || trx.isRewarded;
//           final sourceLabel = isRewardedSource
//               ? l10n.rewarded
//               : (trx.balanceSource?.toLowerCase() == 'regular'
//                     ? l10n.regular
//                     : null);

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppSizes.p16,
//                   vertical: AppSizes.p12,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Date
//                     buildCell(
//                       DateFormat.yMMMd().format(trx.createdAt),
//                       flex: 2,
//                     ),
//                     Expanded(
//                       flex: 4,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             trx.bank != null
//                                 ? "${trx.bank?.bankTitle} (****${trx.bank?.accountNumber})"
//                                 : context.l10n.in_app,
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.ellipsis,
//                             style: textTheme.bodyMedium?.copyWith(
//                               color: colors.textPrimary,
//                             ),
//                           ),
//                           if (sourceLabel != null) ...[
//                             const SizedBox(height: 2),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 6,
//                                 vertical: 1,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isRewardedSource
//                                     ? Colors.amber.shade700.withValues(
//                                         alpha: 0.15,
//                                       )
//                                     : colors.brand.withValues(alpha: 0.12),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 sourceLabel,
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600,
//                                   color: isRewardedSource
//                                       ? Colors.amber.shade800
//                                       : colors.brand,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     buildCell(trx.type, flex: 2, textAlign: TextAlign.center),
//                     // Status
//                     buildCell(
//                       trx.status.capitalised,
//                       flex: 3,
//                       textAlign: TextAlign.center,
//                       color: _getStatusColor(trx.status),
//                       padding: const EdgeInsets.only(left: 12),
//                     ),
//                     // Price
//                     buildCell(
//                       _formatTransactionAmount(trx.amount),
//                       flex: 3,
//                       textAlign: TextAlign.right,
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(thickness: 1, height: 1),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// Widget buildCell(
//   String text, {
//   required int flex,
//   TextAlign textAlign = TextAlign.left,
//   FontWeight fontWeight = FontWeight.normal,
//   EdgeInsetsGeometry? padding,
//   Color? color,
// }) {
//   return Expanded(
//     flex: flex,
//     child: Padding(
//       padding: padding ?? EdgeInsets.zero,
//       child: Text(
//         text,
//         textAlign: textAlign,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(fontWeight: fontWeight, color: color),
//       ),
//     ),
//   );
// }

class TransactionList extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback onLoadMore;
  final bool isFetchingMore;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onLoadMore,
    this.isFetchingMore = false,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final ScrollController _scrollController = ScrollController();

  /// Stores expanded transaction indexes.
  // final Set<int> _expandedIndexes = {};
  int? _expandedIndex;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !widget.isFetchingMore) {
      widget.onLoadMore();
    }
  }

  void _toggleTransaction(int index) {
    setState(() {
      if (_expandedIndex == index) {
        // Same item pe dobara tap kiya to close ho jaye
        _expandedIndex = null;
      } else {
        // Naya item select, purana automatically close ho jayega
        _expandedIndex = index;
      }
    });
  }
  // void _toggleTransaction(int index) {
  //   setState(() {
  //     if (_expandedIndexes.contains(index)) {
  //       _expandedIndexes.remove(index);
  //     } else {
  //       _expandedIndexes.add(index);
  //     }
  //   });
  // }

  String _formatTransactionAmount(double value) {
    final formatted = value % 1 == 0
        ? value.toInt().toString()
        : value.toString();

    return '\$$formatted';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return context.appColors.brand;

      case 'failed':
        return context.appColors.error;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    final items = widget.transactions;

    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.no_transactions_found,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (widget.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final trx = items[index];

          final isExpanded = _expandedIndex == index;
          final isRewardedSource =
              trx.balanceSource?.toLowerCase() == 'rewarded' || trx.isRewarded;

          final sourceLabel = isRewardedSource
              ? l10n.rewarded
              : (trx.balanceSource?.toLowerCase() == 'regular'
                    ? l10n.regular
                    : null);

          // Label from `purpose` for credits that don't come from a bank.
          final purposeLabel = switch (trx.purpose) {
            'driver_referral_bonus' => l10n.transaction_referral_bonus,
            'admin_reward' => l10n.transaction_reward,
            _ => null,
          };

          return Column(
            children: [
              /// Main transaction row
              InkWell(
                onTap: () => _toggleTransaction(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      buildCell(
                        DateFormat.yMMMd().format(trx.createdAt),
                        flex: 2,
                      ),

                      // Bank / In App
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              trx.bank != null
                                  ? "${trx.bank?.bankTitle} "
                                        "(****${trx.bank?.accountNumber})"
                                  : purposeLabel ?? context.l10n.in_app,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),

                            if (sourceLabel != null) ...[
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isRewardedSource
                                      ? Colors.amber.shade700.withValues(
                                          alpha: 0.15,
                                        )
                                      : colors.brand.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  sourceLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isRewardedSource
                                        ? Colors.amber.shade800
                                        : colors.brand,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Type
                      buildCell(trx.type, flex: 2, textAlign: TextAlign.center),

                      // Status
                      buildCell(
                        trx.status.capitalised,
                        flex: 3,
                        textAlign: TextAlign.center,
                        color: _getStatusColor(trx.status),
                        padding: const EdgeInsets.only(left: 12),
                      ),

                      // Price
                      buildCell(
                        _formatTransactionAmount(trx.amount),
                        flex: 3,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),

              /// Expanded transaction details
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: AppSizes.p16,
                          right: AppSizes.p16,
                          bottom: AppSizes.p16,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.p12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaction Details',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _DetailRow(
                                label: 'Date',
                                value: DateFormat.yMMMd().format(trx.createdAt),
                              ),

                              _DetailRow(label: 'Type', value: trx.type),

                              _DetailRow(
                                label: 'Status',
                                value: trx.status.capitalised,
                                valueColor: _getStatusColor(trx.status),
                              ),

                              _DetailRow(
                                label: 'Amount',
                                value: _formatTransactionAmount(trx.amount),
                              ),

                              if (trx.bank != null) ...[
                                _DetailRow(
                                  label: 'Bank',
                                  value: trx.bank?.bankTitle ?? '',
                                ),

                                _DetailRow(
                                  label: 'Account',
                                  value: '****${trx.bank?.accountNumber ?? ''}',
                                ),
                              ],

                              if (sourceLabel != null)
                                _DetailRow(label: 'Source', value: sourceLabel),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const Divider(thickness: 1, height: 1),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildCell(
  String text, {
  required int flex,
  TextAlign textAlign = TextAlign.left,
  FontWeight fontWeight = FontWeight.normal,
  EdgeInsetsGeometry? padding,
  Color? color,
}) {
  return Expanded(
    flex: flex,
    child: Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: fontWeight, color: color),
      ),
    ),
  );
}
