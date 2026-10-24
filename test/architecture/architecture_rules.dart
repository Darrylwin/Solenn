import 'source_file.dart';

const Set<String> _allowedDartLibraries = {
  'dart:async',
  'dart:collection',
  'dart:convert',
  'dart:core',
  'dart:math',
  'dart:typed_data',
};

const Set<String> _allowedDomainPackages = {
  'collection',
  'decimal',
  'equatable',
  'meta',
  'rational',
};

bool _isDomain(String path) =>
    path.startsWith('lib/features/') && path.contains('/domain/');

String _featureOf(String path) => path.split('/')[2];

bool _isAllowedInDomain(String target, String feature) {
  if (target.startsWith('dart:')) return _allowedDartLibraries.contains(target);
  if (!target.startsWith('package:')) return false;

  final package = target.substring('package:'.length).split('/').first;
  if (package == 'solenn') {
    return target.startsWith('package:solenn/features/$feature/domain/');
  }
  return _allowedDomainPackages.contains(package);
}

/// AR-1: domain code is pure Dart.
List<String> domainPurityViolations(Iterable<SourceFile> files) {
  final violations = <String>[];
  for (final file in files.where((file) => _isDomain(file.path))) {
    final feature = _featureOf(file.path);
    for (final target in file.directives) {
      if (!_isAllowedInDomain(target, feature)) {
        violations.add('${file.path}: domain must not import $target');
      }
    }
  }
  return violations;
}

/// AR-3: features never import each other, nor the app layer.
List<String> featureIsolationViolations(Iterable<SourceFile> files) {
  final violations = <String>[];
  for (final file in files.where((f) => f.path.startsWith('lib/features/'))) {
    final feature = _featureOf(file.path);
    for (final target in file.directives) {
      final otherFeature =
          target.startsWith('package:solenn/features/') &&
          !target.startsWith('package:solenn/features/$feature/');
      final app = target.startsWith('package:solenn/app/');
      if (otherFeature || app) {
        violations.add('${file.path}: features must not import $target');
      }
    }
  }
  return violations;
}

/// AR-4: core never depends on features or the app layer.
List<String> coreIndependenceViolations(Iterable<SourceFile> files) {
  final violations = <String>[];
  for (final file in files.where((f) => f.path.startsWith('lib/core/'))) {
    for (final target in file.directives) {
      if (target.startsWith('package:solenn/features/') ||
          target.startsWith('package:solenn/app/')) {
        violations.add('${file.path}: core must not import $target');
      }
    }
  }
  return violations;
}

/// Fichiers générés automatiquement.
bool _isGenerated(String path) =>
    path.startsWith('lib/l10n/') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.endsWith('.mocks.dart');

/// AR-5: package imports only, no relative imports.
List<String> packageImportViolations(Iterable<SourceFile> files) {
  final violations = <String>[];
  for (final file in files.where((f) => !_isGenerated(f.path))) {
    for (final target in file.directives) {
      if (!target.startsWith('dart:') && !target.startsWith('package:')) {
        violations.add('${file.path}: relative import $target');
      }
    }
  }
  return violations;
}
