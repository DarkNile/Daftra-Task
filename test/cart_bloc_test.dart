import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:daftra_task/src/cart/cart_bloc.dart';
import 'package:daftra_task/src/cart/models.dart';
import 'package:daftra_task/src/catalog/item.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CartBloc bloc;
  final item1 = Item(id: 'p01', name: 'Coffee', price: 2.5);
  final item2 = Item(id: 'p02', name: 'Bagel', price: 3.2);

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    HydratedBloc.storage = await HydratedStorage.build(storageDirectory: dir);
    bloc = CartBloc();
  });

  tearDown(() async {
    await HydratedBloc.storage.clear();
  });

  test('initial state is empty', () {
    expect(bloc.state.lines, isEmpty);
    expect(bloc.state.totals.grandTotal, 0);
  });

  blocTest<CartBloc, CartState>(
    'Two different items → correct totals',
    build: () => bloc,
    act: (b) {
      b.add(AddItem(item1));
      b.add(AddItem(item2));
    },
    expect:
        () => [
          isA<CartState>(),
          isA<CartState>().having((s) => s.lines.length, 'lines.length', 2),
        ],
    verify: (b) {
      final subtotal = item1.price + item2.price;
      final vat = double.parse((subtotal * 0.15).toStringAsFixed(2));
      final grand = double.parse((subtotal + vat).toStringAsFixed(2));
      expect(b.state.totals.subtotal, subtotal);
      expect(b.state.totals.vat, vat);
      expect(b.state.totals.grandTotal, grand);
    },
  );

  blocTest<CartBloc, CartState>(
    'Qty + discount changes update totals',
    build: () => bloc,
    act: (b) {
      b.add(AddItem(item1));
      b.add(ChangeQty(item1.id, 3));
      b.add(ChangeDiscount(item1.id, 0.2));
    },
    verify: (b) {
      final subtotal = item1.price * 3 * (1 - 0.2);
      final vat = double.parse((subtotal * 0.15).toStringAsFixed(2));
      final grand = double.parse((subtotal + vat).toStringAsFixed(2));
      expect(
        b.state.totals.subtotal,
        double.parse(subtotal.toStringAsFixed(2)),
      );
      expect(b.state.totals.vat, vat);
      expect(b.state.totals.grandTotal, grand);
    },
  );

  blocTest<CartBloc, CartState>(
    'Clearing cart resets state',
    build: () => bloc,
    act: (b) {
      b.add(AddItem(item1));
      b.add(ClearCart());
    },
    expect:
        () => [
          isA<CartState>(),
          isA<CartState>().having((s) => s.lines, 'lines', isEmpty),
        ],
  );

  blocTest<CartBloc, CartState>(
    'Undo/redo works',
    build: () => bloc,
    act: (b) {
      b.add(AddItem(item1));
      b.add(AddItem(item2));
      b.add(Undo());
      b.add(Redo());
    },
    verify: (b) {
      expect(b.state.lines.length, 2);
    },
  );

  test('Hydration works', () async {
    bloc.add(AddItem(item1));
    await Future.delayed(Duration(milliseconds: 100));
    final json = bloc.toJson(bloc.state);
    final restored = bloc.fromJson(json!);
    expect(restored?.lines.first.item.id, item1.id);
  });
}
