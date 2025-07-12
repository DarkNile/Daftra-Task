import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'item.dart';

/// Events for [CatalogBloc].
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}

/// Event to load the catalog from assets.
class LoadCatalog extends CatalogEvent {}

/// States for [CatalogBloc].
abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

/// State when the catalog is loading.
class CatalogLoading extends CatalogState {}

/// State when the catalog is loaded.
class CatalogLoaded extends CatalogState {
  final List<Item> items;
  const CatalogLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

/// Bloc for loading the product catalog.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(CatalogLoading()) {
    on<LoadCatalog>(_onLoadCatalog);
  }

  Future<void> _onLoadCatalog(
    LoadCatalog event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    final String data = await rootBundle.loadString('assets/catalog.json');
    final List<dynamic> jsonList = json.decode(data);
    final items = jsonList.map((e) => Item.fromJson(e)).toList();
    emit(CatalogLoaded(items));
  }
}
