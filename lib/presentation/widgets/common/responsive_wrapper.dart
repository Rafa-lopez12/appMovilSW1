// lib/presentation/widgets/common/responsive_wrapper.dart
import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool addSafeArea;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.centerContent = true,
    this.maxWidth,
    this.padding,
    this.addSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Aplicar padding responsivo si no se especifica uno
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else {
      content = Padding(
        padding: ResponsiveUtils.getPagePadding(context),
        child: content,
      );
    }

    // Limitar ancho máximo
    final maxContentWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    if (maxContentWidth != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: content,
        ),
      );
    } else if (centerContent) {
      content = Center(child: content);
    }

    // Agregar SafeArea si es necesario
    if (addSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}

// Widget para páginas que necesitan scroll
class ResponsiveScrollView extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final double? maxWidth;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveScrollView({
    Key? key,
    required this.child,
    this.centerContent = true,
    this.maxWidth,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: physics ?? const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 
                       MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: ResponsiveWrapper(
              centerContent: centerContent,
              maxWidth: maxWidth,
              padding: padding,
              addSafeArea: false,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para formularios responsivos
class ResponsiveForm extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveForm({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveScrollView(
      maxWidth: maxWidth ?? (ResponsiveUtils.isMobile(context) ? double.infinity : 400),
      padding: padding,
      child: child,
    );
  }
}

// Extension para hacer widgets más fáciles de usar
extension ResponsiveExtension on Widget {
  Widget responsive({
    bool centerContent = true,
    double? maxWidth,
    EdgeInsets? padding,
    bool addSafeArea = true,
  }) {
    return ResponsiveWrapper(
      centerContent: centerContent,
      maxWidth: maxWidth,
      padding: padding,
      addSafeArea: addSafeArea,
      child: this,
    );
  }

  Widget responsiveScroll({
    bool centerContent = true,
    double? maxWidth,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return ResponsiveScrollView(
      centerContent: centerContent,
      maxWidth: maxWidth,
      padding: padding,
      physics: physics,
      child: this,
    );
  }
}