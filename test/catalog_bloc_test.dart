import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:daftra_task/src/catalog/catalog_bloc.dart';
import 'dart:typed_data';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogBloc', () {
    const catalogJson = '[{"id":"p01","name":"Coffee","price":2.5}]';

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
            'flutter/assets',
            (message) async =>
                ByteData.view(Uint8List.fromList(catalogJson.codeUnits).buffer),
          );
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogLoaded] with correct items',
      build: () => CatalogBloc(),
      act: (bloc) => bloc.add(LoadCatalog()),
      expect:
          () => [
            isA<CatalogLoading>(),
            isA<CatalogLoaded>().having(
              (s) => (s).items.length,
              'items.length',
              1,
            ),
          ],
    );
  });
}
