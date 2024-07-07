import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DropDownBuilder extends StatefulWidget {
  final List<dynamic> groups;
  String selectedGroup;

  DropDownBuilder(
      {super.key, required this.groups, required this.selectedGroup});

  @override
  State<DropDownBuilder> createState() => _DropDownBuilderState();
}

class _DropDownBuilderState extends State<DropDownBuilder> {
  @override
  Widget build(BuildContext context) {
    final groups = widget.groups;
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: DropdownSearch<String>(
        items: List.generate(groups.length, (index) {
          return groups[index];
        }),
        dropdownDecoratorProps: DropDownDecoratorProps(
          baseStyle: Theme.of(context).textTheme.labelLarge,
          dropdownSearchDecoration: InputDecoration(
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
            errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
            helperStyle: Theme.of(context).inputDecorationTheme.helperStyle,
            border: OutlineInputBorder(),
            labelText: "Выберите группу",
          ),
        ),
        popupProps: PopupProps.menu(
          itemBuilder: (context, name, b) {
            return InkWell(
              onTap: () {},
              child: ListTile(
                title: Text(
                  name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            );
          },
          menuProps: MenuProps(
            shadowColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autocorrect: false,
            style: Theme.of(context).textTheme.labelLarge,
            decoration: InputDecoration(
              enabledBorder:
                  Theme.of(context).inputDecorationTheme.enabledBorder,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
              errorStyle: Theme.of(context).inputDecorationTheme.errorStyle,
              helperStyle: Theme.of(context).inputDecorationTheme.helperStyle,
            ),
          ),
        ),
        onChanged: (name) {
          setState(() {
            if (name != null) {
              widget.selectedGroup = name;
            }
          });
        },
      ),
    );
  }
}
