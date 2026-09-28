import 'package:flutter/foundation.dart';

class Injector {
  Injector._();
  static final Injector I = Injector._();

  final Map<Type, dynamic> _singletons = <Type, dynamic>{};
  final Map<Type, dynamic Function(Injector)> _lazySingletonBuilders = <Type, dynamic Function(Injector)>{};
  final Map<Type, dynamic Function(Injector)> _factories = <Type, dynamic Function(Injector)>{};

  bool isRegistered<T>() => _singletons.containsKey(T) || _lazySingletonBuilders.containsKey(T) || _factories.containsKey(T);

  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerLazySingleton<T>(T Function(Injector) builder) {
    _lazySingletonBuilders[T] = builder;
  }

  void registerFactory<T>(T Function(Injector) factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) return _singletons[T] as T;
    if (_lazySingletonBuilders.containsKey(T)) {
      final created = _lazySingletonBuilders[T]!(this);
      _singletons[T] = created;
      _lazySingletonBuilders.remove(T);
      return created as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!(this) as T;
    }
    throw FlutterError('Service of type $T is not registered in Injector');
  }

  void reset() {
    _singletons.clear();
    _lazySingletonBuilders.clear();
    _factories.clear();
  }
}
