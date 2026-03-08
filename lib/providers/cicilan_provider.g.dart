// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cicilan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cicilanPaidCountHash() => r'fa29d74116686123acc3cd36a764b562261a61d4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [cicilanPaidCount].
@ProviderFor(cicilanPaidCount)
const cicilanPaidCountProvider = CicilanPaidCountFamily();

/// See also [cicilanPaidCount].
class CicilanPaidCountFamily extends Family<int> {
  /// See also [cicilanPaidCount].
  const CicilanPaidCountFamily();

  /// See also [cicilanPaidCount].
  CicilanPaidCountProvider call(
    String cicilanId,
  ) {
    return CicilanPaidCountProvider(
      cicilanId,
    );
  }

  @override
  CicilanPaidCountProvider getProviderOverride(
    covariant CicilanPaidCountProvider provider,
  ) {
    return call(
      provider.cicilanId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cicilanPaidCountProvider';
}

/// See also [cicilanPaidCount].
class CicilanPaidCountProvider extends AutoDisposeProvider<int> {
  /// See also [cicilanPaidCount].
  CicilanPaidCountProvider(
    String cicilanId,
  ) : this._internal(
          (ref) => cicilanPaidCount(
            ref as CicilanPaidCountRef,
            cicilanId,
          ),
          from: cicilanPaidCountProvider,
          name: r'cicilanPaidCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cicilanPaidCountHash,
          dependencies: CicilanPaidCountFamily._dependencies,
          allTransitiveDependencies:
              CicilanPaidCountFamily._allTransitiveDependencies,
          cicilanId: cicilanId,
        );

  CicilanPaidCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cicilanId,
  }) : super.internal();

  final String cicilanId;

  @override
  Override overrideWith(
    int Function(CicilanPaidCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CicilanPaidCountProvider._internal(
        (ref) => create(ref as CicilanPaidCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cicilanId: cicilanId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _CicilanPaidCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CicilanPaidCountProvider && other.cicilanId == cicilanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cicilanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CicilanPaidCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `cicilanId` of this provider.
  String get cicilanId;
}

class _CicilanPaidCountProviderElement extends AutoDisposeProviderElement<int>
    with CicilanPaidCountRef {
  _CicilanPaidCountProviderElement(super.provider);

  @override
  String get cicilanId => (origin as CicilanPaidCountProvider).cicilanId;
}

String _$totalCicilanThisMonthHash() =>
    r'63e98dd333c8bb3a6eb3ff10da29c54522c52590';

/// See also [totalCicilanThisMonth].
@ProviderFor(totalCicilanThisMonth)
final totalCicilanThisMonthProvider = AutoDisposeProvider<double>.internal(
  totalCicilanThisMonth,
  name: r'totalCicilanThisMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalCicilanThisMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalCicilanThisMonthRef = AutoDisposeProviderRef<double>;
String _$cicilanListHash() => r'b747295983cba767c24303ffe26033bc870c3cb2';

/// See also [CicilanList].
@ProviderFor(CicilanList)
final cicilanListProvider =
    AutoDisposeNotifierProvider<CicilanList, List<Cicilan>>.internal(
  CicilanList.new,
  name: r'cicilanListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cicilanListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CicilanList = AutoDisposeNotifier<List<Cicilan>>;
String _$cicilanPaymentsHash() => r'2576dac3499f05ae045215b8a5f3dacff7f1724c';

abstract class _$CicilanPayments
    extends BuildlessAutoDisposeNotifier<List<CicilanPayment>> {
  late final String cicilanId;

  List<CicilanPayment> build(
    String cicilanId,
  );
}

/// See also [CicilanPayments].
@ProviderFor(CicilanPayments)
const cicilanPaymentsProvider = CicilanPaymentsFamily();

/// See also [CicilanPayments].
class CicilanPaymentsFamily extends Family<List<CicilanPayment>> {
  /// See also [CicilanPayments].
  const CicilanPaymentsFamily();

  /// See also [CicilanPayments].
  CicilanPaymentsProvider call(
    String cicilanId,
  ) {
    return CicilanPaymentsProvider(
      cicilanId,
    );
  }

  @override
  CicilanPaymentsProvider getProviderOverride(
    covariant CicilanPaymentsProvider provider,
  ) {
    return call(
      provider.cicilanId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cicilanPaymentsProvider';
}

/// See also [CicilanPayments].
class CicilanPaymentsProvider extends AutoDisposeNotifierProviderImpl<
    CicilanPayments, List<CicilanPayment>> {
  /// See also [CicilanPayments].
  CicilanPaymentsProvider(
    String cicilanId,
  ) : this._internal(
          () => CicilanPayments()..cicilanId = cicilanId,
          from: cicilanPaymentsProvider,
          name: r'cicilanPaymentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cicilanPaymentsHash,
          dependencies: CicilanPaymentsFamily._dependencies,
          allTransitiveDependencies:
              CicilanPaymentsFamily._allTransitiveDependencies,
          cicilanId: cicilanId,
        );

  CicilanPaymentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cicilanId,
  }) : super.internal();

  final String cicilanId;

  @override
  List<CicilanPayment> runNotifierBuild(
    covariant CicilanPayments notifier,
  ) {
    return notifier.build(
      cicilanId,
    );
  }

  @override
  Override overrideWith(CicilanPayments Function() create) {
    return ProviderOverride(
      origin: this,
      override: CicilanPaymentsProvider._internal(
        () => create()..cicilanId = cicilanId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cicilanId: cicilanId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CicilanPayments, List<CicilanPayment>>
      createElement() {
    return _CicilanPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CicilanPaymentsProvider && other.cicilanId == cicilanId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cicilanId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CicilanPaymentsRef
    on AutoDisposeNotifierProviderRef<List<CicilanPayment>> {
  /// The parameter `cicilanId` of this provider.
  String get cicilanId;
}

class _CicilanPaymentsProviderElement
    extends AutoDisposeNotifierProviderElement<CicilanPayments,
        List<CicilanPayment>> with CicilanPaymentsRef {
  _CicilanPaymentsProviderElement(super.provider);

  @override
  String get cicilanId => (origin as CicilanPaymentsProvider).cicilanId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
