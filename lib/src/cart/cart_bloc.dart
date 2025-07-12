import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../catalog/item.dart';
import 'models.dart';

/// Events for [CartBloc].
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

/// Add an item to the cart (or increase quantity if exists).
class AddItem extends CartEvent {
  final Item item;
  const AddItem(this.item);
  @override
  List<Object?> get props => [item];
}

/// Remove an item from the cart.
class RemoveItem extends CartEvent {
  final String itemId;
  const RemoveItem(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Change the quantity of an item in the cart.
class ChangeQty extends CartEvent {
  final String itemId;
  final int quantity;
  const ChangeQty(this.itemId, this.quantity);
  @override
  List<Object?> get props => [itemId, quantity];
}

/// Change the discount for an item in the cart (0.0 - 1.0).
class ChangeDiscount extends CartEvent {
  final String itemId;
  final double discount;
  const ChangeDiscount(this.itemId, this.discount);
  @override
  List<Object?> get props => [itemId, discount];
}

/// Clear the cart.
class ClearCart extends CartEvent {}

/// Undo the last cart action.
class Undo extends CartEvent {}

/// Redo the last undone cart action.
class Redo extends CartEvent {}

/// Bloc for managing the cart state, business rules, undo/redo, and hydration.
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  static const double vatRate = 0.15;
  static const int maxHistory = 20;

  final List<CartState> _undoStack = [];
  final List<CartState> _redoStack = [];

  CartBloc() : super(CartState.initial()) {
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<ChangeQty>(_onChangeQty);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ClearCart>(_onClearCart);
    on<Undo>(_onUndo);
    on<Redo>(_onRedo);
  }

  void _pushToUndo(CartState state) {
    _undoStack.add(state);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    _pushToUndo(state);
    final idx = state.lines.indexWhere((l) => l.item.id == event.item.id);
    List<CartLine> newLines;
    if (idx == -1) {
      newLines = List.from(state.lines)
        ..add(CartLine(item: event.item, quantity: 1));
    } else {
      final line = state.lines[idx];
      newLines = List.from(state.lines)
        ..[idx] = line.copyWith(quantity: line.quantity + 1);
    }
    emit(_recalculate(newLines));
  }

  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    _pushToUndo(state);
    final newLines =
        state.lines.where((l) => l.item.id != event.itemId).toList();
    emit(_recalculate(newLines));
  }

  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    _pushToUndo(state);
    final idx = state.lines.indexWhere((l) => l.item.id == event.itemId);
    if (idx == -1) return;
    if (event.quantity <= 0) {
      add(RemoveItem(event.itemId));
      return;
    }
    final line = state.lines[idx];
    final newLines = List<CartLine>.from(state.lines)
      ..[idx] = line.copyWith(quantity: event.quantity);
    emit(_recalculate(newLines));
  }

  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    _pushToUndo(state);
    final idx = state.lines.indexWhere((l) => l.item.id == event.itemId);
    if (idx == -1) return;
    final line = state.lines[idx];
    final newLines = List<CartLine>.from(state.lines)
      ..[idx] = line.copyWith(discount: event.discount.clamp(0.0, 1.0));
    emit(_recalculate(newLines));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _pushToUndo(state);
    emit(CartState.initial());
  }

  void _onUndo(Undo event, Emitter<CartState> emit) {
    if (_undoStack.isEmpty) return;
    _redoStack.add(state);
    emit(_undoStack.removeLast());
  }

  void _onRedo(Redo event, Emitter<CartState> emit) {
    if (_redoStack.isEmpty) return;
    _undoStack.add(state);
    emit(_redoStack.removeLast());
  }

  CartState _recalculate(List<CartLine> lines) {
    double subtotal = 0;
    double discountTotal = 0;
    for (final line in lines) {
      subtotal += line.lineNet;
      discountTotal += line.item.price * line.quantity * line.discount;
    }
    final vat = double.parse((subtotal * vatRate).toStringAsFixed(2));
    final grandTotal = double.parse((subtotal + vat).toStringAsFixed(2));
    return CartState(
      lines: List.unmodifiable(lines),
      totals: Totals(
        subtotal: double.parse(subtotal.toStringAsFixed(2)),
        vat: vat,
        discount: double.parse(discountTotal.toStringAsFixed(2)),
        grandTotal: grandTotal,
      ),
    );
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      return CartState.fromJson(json);
    } catch (_) {
      return CartState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) => state.toJson();
}
