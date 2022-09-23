import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields/responsive/responsive.dart';
import 'package:folly_fields/responsive/responsive_builder.dart';
import 'package:folly_fields/responsive/responsive_form_field.dart';
import 'package:folly_fields/responsive/responsive_grid.dart';
import 'package:folly_fields/widgets/empty_button.dart';
import 'package:folly_fields/widgets/field_group.dart';
import 'package:folly_fields/widgets/folly_divider.dart';
import 'package:folly_fields/widgets/header_cell.dart';
import 'package:folly_fields/widgets/table_button.dart';
import 'package:folly_fields/widgets/table_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
// TODO(edufolly): Test layout with DataTable.
// TODO(edufolly): Customize messages.
// TODO(edufolly): Create controller??
class TableField<T extends AbstractModel<Object>>
    extends ResponsiveFormField<List<T>> {
  ///
  ///
  ///
  TableField({
    required List<T> super.initialValue,
    required AbstractUIBuilder<T> uiBuilder,
    required AbstractConsumer<T> consumer,
    required List<String> columns,
    required List<Responsive> Function(
      BuildContext context,
      T row,
      int index,
      List<T> data,
      bool enabled,
      List<String> labels,
    )
        buildRow,
    List<int>? columnsFlex,
    Future<bool> Function(BuildContext context, List<T> data)? beforeAdd,
    Future<bool> Function(BuildContext context, T row, int index, List<T> data)?
        removeRow,
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    super.enabled,
    bool showAddButton = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    Widget Function(
      BuildContext context,
      List<T> data,
      bool isCard,
    )?
        buildFooter,
    InputDecoration? decoration,
    EdgeInsets padding = const EdgeInsets.all(8),
    super.sizeExtraSmall,
    super.sizeSmall,
    super.sizeMedium,
    super.sizeLarge,
    super.sizeExtraLarge,
    super.minHeight,
    ResponsiveSize? changeToCard,
    double? elevation,
    super.key,
  })  : assert(
          columnsFlex == null || columnsFlex.length == columns.length,
          'columnsFlex must be null or columnsFlex.length equals to '
          'columns.length.',
        ),
        super(
          onSaved: enabled && onSaved != null
              ? (List<T>? value) => onSaved(value)
              : null,
          validator: enabled && validator != null
              ? (List<T>? value) => validator(value)
              : null,
          autovalidateMode: autoValidateMode,
          builder: (FormFieldState<List<T>> field) {
            TextStyle? columnHeaderTheme =
                Theme.of(field.context).textTheme.subtitle2;

            Color disabledColor = Theme.of(field.context).disabledColor;

            if (columnHeaderTheme != null && !enabled) {
              columnHeaderTheme =
                  columnHeaderTheme.copyWith(color: disabledColor);
            }

            InputDecoration effectiveDecoration = (decoration ??
                    InputDecoration(
                      labelText: uiBuilder.superPlural(field.context),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      enabled: enabled,
                      errorText: field.errorText,
                    ))
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return FieldGroup(
              padding: padding,
              decoration: effectiveDecoration,
              children: <Widget>[
                if (field.value!.isEmpty)

                  /// Empty table
                  SizedBox(
                    height: 75,
                    child: Center(
                      child: Text(
                        'Sem ${uiBuilder.superPlural(field.context)} '
                        'até o momento.',
                      ),
                    ),
                  )
                else

                  /// Table
                  ResponsiveBuilder(
                    builder: (
                      BuildContext context,
                      ResponsiveSize responsiveSize,
                    ) {
                      bool isCard = false;
                      List<Widget> columnData = <Widget>[];

                      if (changeToCard != null &&
                          responsiveSize <= changeToCard) {
                        isCard = true;

                        /// Table data
                        for (MapEntry<int, T> entry
                            in field.value!.asMap().entries) {
                          columnData.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                elevation: elevation,
                                child: ResponsiveGrid(
                                  margin: const EdgeInsets.all(4),
                                  children: <Responsive>[
                                    /// Fields
                                    ...buildRow(
                                      field.context,
                                      entry.value,
                                      entry.key,
                                      field.value!,
                                      enabled,
                                      columns,
                                    ),

                                    /// Delete button
                                    if (removeRow != null)
                                      TableButton(
                                        enabled: enabled,
                                        iconData: FontAwesomeIcons.trashCan,
                                        padding: const EdgeInsets.all(8),
                                        label: 'REMOVER ITEM',
                                        onPressed: () async {
                                          bool go = await removeRow(
                                            field.context,
                                            entry.value,
                                            entry.key,
                                            field.value!,
                                          );
                                          if (!go) {
                                            return;
                                          }
                                          field.value!.removeAt(entry.key);
                                          field.didChange(field.value);
                                        },
                                        sizeMedium: 12,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        /// Header
                        columnData.add(
                          Row(
                            children: <Widget>[
                              /// Columns Names
                              ...columns
                                  .asMap()
                                  .entries
                                  .map<Widget>(
                                    (MapEntry<int, String> entry) => HeaderCell(
                                      flex: columnsFlex?[entry.key] ?? 1,
                                      child: Text(
                                        entry.value,
                                        style: columnHeaderTheme,
                                      ),
                                    ),
                                  )
                                  .toList(),

                              /// Empty column to delete button
                              if (removeRow != null) const EmptyButton(),
                            ],
                          ),
                        );

                        /// Table data
                        for (MapEntry<int, T> entry
                            in field.value!.asMap().entries) {
                          columnData.addAll(
                            <Widget>[
                              /// Divider
                              FollyDivider(enabled: enabled),

                              /// Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  /// Cells
                                  ...buildRow(
                                    field.context,
                                    entry.value,
                                    entry.key,
                                    field.value!,
                                    enabled,
                                    List<String>.filled(columns.length, ''),
                                  )
                                      .asMap()
                                      .entries
                                      .map<Widget>(
                                        (MapEntry<int, Widget> entry) =>
                                            Flexible(
                                          flex: columnsFlex?[entry.key] ?? 1,
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: entry.value,
                                          ),
                                        ),
                                      )
                                      .toList(),

                                  /// Delete button
                                  if (removeRow != null)
                                    TableIconButton(
                                      enabled: enabled,
                                      iconData: FontAwesomeIcons.trashCan,
                                      onPressed: () async {
                                        bool go = await removeRow(
                                          field.context,
                                          entry.value,
                                          entry.key,
                                          field.value!,
                                        );
                                        if (!go) {
                                          return;
                                        }
                                        field.value!.removeAt(entry.key);
                                        field.didChange(field.value);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          );
                        }
                      }

                      /// Footer
                      if (buildFooter != null) {
                        columnData.add(
                          buildFooter(
                            field.context,
                            field.value!,
                            isCard,
                          ),
                        );
                      }

                      return Column(children: columnData);
                    },
                  ),

                /// Add button
                if (showAddButton)
                  TableButton(
                    enabled: enabled,
                    iconData: FontAwesomeIcons.plus,
                    label: 'Adicionar ${uiBuilder.superSingle(field.context)}',
                    onPressed: () async {
                      if (beforeAdd != null) {
                        bool go = await beforeAdd(field.context, field.value!);
                        if (!go) {
                          return;
                        }
                      }

                      field.value!.add(consumer.fromJson(<String, dynamic>{}));
                      field.didChange(field.value);
                    },
                  ),
              ],
            );
          },
        );
}
