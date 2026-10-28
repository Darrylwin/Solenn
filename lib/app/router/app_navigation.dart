import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:solenn/app/router/app_route.dart';
import 'package:solenn/features/account/domain/legal/legal_document_kind.dart';

/// Opens the account screen.
void openAccount(BuildContext context) => unawaited(
  Navigator.of(context).pushNamed<void>(AppRoute.account.path),
);

/// Opens the legal text [kind].
void openLegal(BuildContext context, LegalDocumentKind kind) => unawaited(
  Navigator.of(context).pushNamed<void>(
    AppRoute.accountLegal.path,
    arguments: kind,
  ),
);
