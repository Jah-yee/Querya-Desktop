import 'package:flutter/material.dart' as material;
import 'package:querya_desktop/core/ui/querya_control_tokens.dart';
import 'package:querya_desktop/shared/services/data_export_service.dart';
import 'package:querya_desktop/shared/widgets/querya_action_menu.dart'
    show QueryaActionMenuItem;
import 'package:querya_desktop/shared/widgets/querya_menu_button.dart';

/// The Export / Copy menu of result and table toolbars: CSV, JSON, Markdown
/// and SQL dump, saved to a file or copied ([isSave]).
class ExportMenuButton extends material.StatelessWidget {
  const ExportMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onSelected,
    required this.isSave,
  });

  final String label;
  final material.IconData icon;
  final material.ValueChanged<DataExportFormat> onSelected;
  final bool isSave;

  @override
  material.Widget build(material.BuildContext context) {
    return QueryaMenuButton<DataExportFormat>(
      label: label,
      icon: icon,
      size: QueryaControlSize.sm,
      onSelected: onSelected,
      items: [
        QueryaActionMenuItem(
          value: DataExportFormat.csv,
          icon: material.Icons.table_chart_outlined,
          label: isSave ? 'CSV (.csv)' : 'Copy as CSV',
        ),
        QueryaActionMenuItem(
          value: DataExportFormat.json,
          icon: material.Icons.data_object_rounded,
          label: isSave ? 'JSON (.json)' : 'Copy as JSON',
        ),
        QueryaActionMenuItem(
          value: DataExportFormat.markdown,
          icon: material.Icons.code_rounded,
          label: isSave ? 'Markdown Table (.md)' : 'Copy as Markdown Table',
        ),
        QueryaActionMenuItem(
          value: DataExportFormat.sqlDump,
          icon: material.Icons.storage_rounded,
          label: isSave ? 'SQL INSERT Dump (.sql)' : 'Copy as SQL Dump',
        ),
      ],
    );
  }
}
