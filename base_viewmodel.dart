import 'package:flutter/material.dart';

/// [BaseViewModel]'a meşgul olma durumu ve hata durumunun kontrolü verilir
class BaseViewModel extends ChangeNotifier with BusyAndErrorStateHelper {
  void rebuildUi() => notifyListeners();
}
// --------------------------------------------------------------- //

/// Meşgul olma ve hata durumunun kontrolünü sağlayan sınıftır
mixin BusyAndErrorStateHelper on ChangeNotifier {
  final Map<int, bool> _busyStates = <int, bool>{};

  /// Eğer varsa bir nesnenin meşgul durumunu döndürür. Yoksa false döner
  bool _isBusy(Object? object) => _busyStates[object.hashCode] ?? false;

  /// ViewModel'in meşgul durumunu döndürür
  bool get isBusy => _isBusy(this);

  // Herhangi bir nesnenin hala meşgul bir durumu varsa true döndürür.
  bool get anyObjectsBusy => _busyStates.values.any((busy) => busy);

  /// Nesne için meşgul durumu belirtilen değere eşitler ve dinleyicilere bildirim gönderir
  /// Eğer basit bir tip kullanıyorsanız değer DEĞİŞTİRİLMEMELİDİR, çünkü Hashcode == değeri kullanır
  void setBusyForObject(Object? object, {required bool value}) {
    _busyStates[object.hashCode] = value;
    notifyListeners();
  }

  /// ViewModel'i meşgul olarak işaretler ve dinleyicilere bildirim gönderir
  void setBusy({required bool value}) => setBusyForObject(this, value: value);

  /// Verilen busyKey meşgul ise busyData, değilse realData döner
  /// Eğer busyKey verilmemişse ve model meşgul ise busyData döner
  /// Eğer realData null ise busyData döner
  T skeletonData<T>({
    required T? realData,
    required T busyData,
    Object? busyKey,
  }) {
    final isBusyKeySupplied = busyKey != null;
    if ((isBusyKeySupplied && _isBusy(busyKey)) || realData == null) {
      return busyData;
    } else if (!isBusyKeySupplied && isBusy) {
      return busyData;
    }

    return realData;
  }

  /// ViewModel'i meşgul olarak işaretler, Future çalıştırır ve tamamlandığında meşgul durumu kaldırır.
  /// [throwException] değeri `false` ise [Exception] yeniden fırlatılır
  Future<T> runBusyFuture<T>(
    Future<T> busyFuture, {
    Object? busyObject,
    bool throwException = false,
  }) async {
    _setBusyForModelOrObject(true, busyObject: busyObject);
    try {
      final value = await runErrorFuture<T>(
        busyFuture,
        key: busyObject,
        throwException: throwException,
      );
      return value;
    } catch (e) {
      if (throwException) rethrow;
      return Future.value();
    } finally {
      _setBusyForModelOrObject(false, busyObject: busyObject);
    }
  }

  void _setBusyForModelOrObject(bool value, {Object? busyObject}) {
    if (busyObject != null) {
      setBusyForObject(busyObject, value: value);
    } else {
      setBusyForObject(this, value: value);
    }
  }

  final Map<int, dynamic> _errorStates = <int, dynamic>{};
  T hasErrorObject<T>(Object object) => _errorStates[object.hashCode] as T;

  /// ViewModel'de hata var mı durumunu döndürür
  bool get hasError => hasErrorObject<dynamic>(this) != null;

  /// ViewModel'in hata durumunu döndürür
  T modelError<T>() => hasErrorObject<T>(this);

  /// Tüm hataları temizler
  void clearErrors() => _errorStates.clear();

  /// ViewModel için bir anahtar için hata olup olmadığını gösteren bir boolean döndürür
  bool hasErrorForKey(Object key) => hasErrorObject<dynamic>(key) != null;

  /// ViewModel için hata belirler
  void setError(dynamic error) => setErrorForObject(this, error);

  void setErrorForModelOrObject(dynamic value, {Object? key}) {
    if (key != null) {
      setErrorForObject(key, value);
    } else {
      setErrorForObject(this, value);
    }
  }

  /// Nesne için hata durumunu belirtilen değere eşitler ve dinleyicilere bildirim gönderir
  /// Eğer basit bir tip kullanıyorsanız değer DEĞİŞTİRİLMEMELİDİR, çünkü Hashcode == değeri kullanır
  void setErrorForObject(Object object, dynamic value) {
    _errorStates[object.hashCode] = value;
    notifyListeners();
  }

  Future<T> runErrorFuture<T>(
    Future<T> future, {
    Object? key,
    bool throwException = false,
  }) async {
    try {
      setErrorForModelOrObject(null, key: key);
      return await future;
    } catch (e) {
      setErrorForModelOrObject(e, key: key);
      onFutureError(e, key);
      if (throwException) rethrow;
      return Future.value();
    }
  }

  /// Future bir hatayı fırlattığında çağrılan fonksiyon
  /// Override edilerek hatanın kontrolü sağlanabilir
  void onFutureError(dynamic error, Object? key) {}
}
