import 'package:flutter/cupertino.dart' show showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:solenn/core/design_system/theme/solenn_context.dart';
import 'package:solenn/core/design_system/tokens/solenn_colors_derived.dart';
import 'package:solenn/core/platform/platform_style.dart';

const double _grabberWidth = 40;
const double _grabberHeight = 5;
const double _maxHeightFactor = 0.9;

/// Key of the iOS grabber, exposed so tests can assert its presence.
const Key solennSheetGrabberKey = Key('solenn.sheet.grabber');

/// Presents a bottom sheet in the dialect of the host platform.
///
/// - Android: a Material 3 modal bottom sheet, with the drag handle of the
///   theme.
/// - iOS: a Cupertino modal popup attached to the bottom, with the same
///   surface and a grabber drawn by [SolennSheetScaffold].
///
/// Both are sized by their content. Flutter's Cupertino page sheet has no
/// medium detent yet, so it would turn a short confirmation into a full-height
/// page. The content builder should return a [SolennSheetScaffold].
Future<T?> showSolennSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  if (context.usesCupertinoStyle) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: context.colors.scrim,
      barrierDismissible: isDismissible,
      builder: (sheetContext) =>
          _CupertinoSheetSurface(child: builder(sheetContext)),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    constraints: BoxConstraints(maxWidth: context.spacing.maxContentWidth),
    builder: builder,
  );
}

class _CupertinoSheetSurface extends StatelessWidget {
  const _CupertinoSheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.spacing.maxContentWidth,
          maxHeight: height * _maxHeightFactor,
        ),
        child: Material(
          color: context.colors.surfaceElevated,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.radii.sheet),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Standard padding, safe-area handling and scrolling for sheet content.
///
/// It also draws the iOS grabber; on Android the theme draws the drag handle.
class SolennSheetScaffold extends StatelessWidget {
  /// Creates the scaffold around [child].
  const SolennSheetScaffold({required this.child, super.key});

  /// The sheet content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.xxl,
        0,
        spacing.xxl,
        spacing.xxl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.usesCupertinoStyle) const _Grabber(),
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(top: spacing.md, bottom: spacing.xl),
      child: Center(
        child: DecoratedBox(
          key: solennSheetGrabberKey,
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: context.colors.sheetHandle,
          ),
          child: const SizedBox(width: _grabberWidth, height: _grabberHeight),
        ),
      ),
    );
  }
}
