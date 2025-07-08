import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:frappify/number_card/number_card.dart';

class NumberCardPage extends StatelessWidget {
  const NumberCardPage({
    required this.name,
    super.key,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NumberCardCubit(
        frappe: context.read<FrappeClient>(),
      )..loadNumberCard(name),
      child: const NumberCardView(),
    );
  }
}

class NumberCardView extends StatelessWidget {
  const NumberCardView({super.key});

  Color _getPercentColor(String percent, ShadThemeData theme) {
    try {
      final numericString = percent.replaceAll(RegExp('[^0-9.-]'), '');
      final value = double.tryParse(numericString) ?? 0;

      return value > 0 ? Colors.green : theme.colorScheme.foreground;
    } catch (e) {
      return theme.colorScheme.foreground;
    }
  }

  String _formatPercentage(String percent) {
    try {
      final numericString = percent.replaceAll(RegExp('[^0-9.-]'), '');
      final value = double.tryParse(numericString) ?? 0;
      return '${value.round()}%';
    } catch (e) {
      return percent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return BlocBuilder<NumberCardCubit, NumberCardState>(
      builder: (context, state) {
        return ShadCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: 400,
          border: Border.all(
            color: theme.colorScheme.border,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    state.title ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<NumberCardCubit>().loadNumberCard(state.id!);
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                ],
              ),
              Text(
                state.value ?? '0'.split('.')[0],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: theme.colorScheme.foreground,
                ),
              ),
              Row(
                spacing: 5,
                children: [
                  Text(
                    _formatPercentage(state.percent ?? '0'),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: _getPercentColor(state.percent ?? '0', theme),
                    ),
                  ),
                  if (double.tryParse(state.percent ?? '0')! != 0 ||
                      double.tryParse(state.percent ?? '0')! < 0)
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: double.tryParse(state.percent ?? '0')! > 0
                            ? Colors.green.shade500
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        double.tryParse(state.percent ?? '0')! > 0
                            ? HugeIcons.strokeRoundedArrowUpRight01
                            : HugeIcons.strokeRoundedArrowDownLeft01,
                        size: 18,
                        color: double.tryParse(state.percent ?? '0')! > 0
                            ? Colors.white
                            : theme.colorScheme.foreground,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
