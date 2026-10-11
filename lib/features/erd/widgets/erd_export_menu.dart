import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_menu_button.dart';

/// Entries of the diagram's Export menu.
enum ErdExportAction {
  mermaid,
  svg,
  png,
  pdfA4,
  pdfA3,
  dbml,
  copyMermaid,
  copyDbml,
  toggleTheme,
}

/// The toolbar's Export menu.
class ErdExportMenu extends material.StatelessWidget {
  const ErdExportMenu({super.key, required this.onSelected});

  final void Function(ErdExportAction action) onSelected;

  @override
  material.Widget build(material.BuildContext context) {
    return QueryaMenuButton<ErdExportAction>(
      key: const material.ValueKey('erd_export'),
      items: const [
        QueryaActionMenuItem(
          value: ErdExportAction.toggleTheme,
          label: 'Toggle export theme (light / current)',
          icon: material.Icons.palette_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.mermaid,
          label: 'Mermaid (.mmd)',
          icon: material.Icons.account_tree_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.svg,
          label: 'SVG',
          icon: material.Icons.polyline_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.png,
          label: 'PNG',
          icon: material.Icons.image_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.pdfA4,
          label: 'PDF (A4)',
          icon: material.Icons.picture_as_pdf_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.pdfA3,
          label: 'PDF (A3)',
          icon: material.Icons.picture_as_pdf_outlined,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.dbml,
          label: 'DBML (.dbml)',
          icon: material.Icons.code_rounded,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.copyDbml,
          label: 'Copy DBML',
          icon: material.Icons.content_copy_rounded,
        ),
        QueryaActionMenuItem(
          value: ErdExportAction.copyMermaid,
          label: 'Copy Mermaid',
          icon: material.Icons.content_copy_rounded,
        ),
      ],
      onSelected: onSelected,
      label: 'Export',
      icon: material.Icons.file_download_outlined,
    );
  }
}
