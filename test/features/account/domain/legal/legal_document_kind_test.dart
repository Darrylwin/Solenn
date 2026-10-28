import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';

void main() {
  test('should cover the two bundled legal texts', () {
    expect(LegalDocumentKind.values.toSet(), {
      LegalDocumentKind.terms,
      LegalDocumentKind.privacy,
    });
  });

  test('should name the asset file of each text', () {
    for (final kind in LegalDocumentKind.values) {
      expect(
        File('assets/legal/${kind.name}.txt').existsSync(),
        isTrue,
        reason: '$kind',
      );
    }
  });
}
