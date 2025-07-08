import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frappe_client/frappe_client.dart';

part 'number_card_state.dart';

class NumberCardCubit extends Cubit<NumberCardState> {
  NumberCardCubit({
    required this.frappe,
  }) : super(NumberCardState.initial());

  final FrappeClient frappe;

  Future<void> loadNumberCard(String name) async {
    final numberCardValue = await frappe.getNumberCard(
      name,
    );

    emit(
      state.copyWith(
        id: name,
        title: name,
        value: numberCardValue.message.toString(),
      ),
    );
  }
}
