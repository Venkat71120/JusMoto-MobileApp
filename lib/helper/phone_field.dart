import 'dart:convert';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/components/field_label.dart';

class PhoneField extends StatelessWidget {
  final ValueNotifier<Phone?> phone;
  final controller;
  final String? hintText;
  final String? label;
  final searchHintText;
  final lengthErrorText;
  final bool isRequired;
  PhoneField(
      {required this.phone,
      required this.controller,
      this.hintText,
      this.label,
      this.searchHintText,
      this.lengthErrorText = '',
      this.isRequired = false,
      super.key});

  List<Phone> countryList = [];
  ValueNotifier searchedCountry = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    ValueNotifier selectedCountry = ValueNotifier("_value");
    loadCountries();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label: label ?? LocalKeys.phone, isRequired: isRequired),
        ValueListenableBuilder(
          valueListenable: phone,
          builder: (context, value, child) => TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.always,
            keyboardType: TextInputType.number,
            maxLength: phoneLength(value),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: ValueListenableBuilder(
                valueListenable: phone,
                builder: (context, value, child) => GestureDetector(
                  onTap: () async {
                    searchedCountry.value = '';
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: context.color.accentContrastColor,
                          ),
                          constraints: BoxConstraints(
                              maxHeight: context.height / 2 +
                                  (MediaQuery.of(context).viewInsets.bottom /
                                      2)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: searchHintText,
                                    ),
                                    onChanged: (value) {
                                      searchedCountry.value = value;
                                    }),
                              ),
                              ValueListenableBuilder(
                                valueListenable: searchedCountry,
                                builder: (context, value, child) {
                                  List searchedCountryList = countryList;
                                  debugPrint(searchedCountry.value.toString());
                                  if (value.isNotEmpty) {
                                    searchedCountryList = countryList
                                        .where((element) => element.name
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  }

                                  return searchedCountryList.isEmpty
                                      ? Text(LocalKeys.noResultFound)
                                      : Expanded(
                                          child: ListView.separated(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.only(
                                                  right: 20,
                                                  left: 20,
                                                  bottom: 20),
                                              itemBuilder: (context, index) {
                                                final element =
                                                    searchedCountryList[index];
                                                return InkWell(
                                                  onTap: () {
                                                    phone.value = element;
                                                    Navigator.pop(context);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 14),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              context.width / 2,
                                                          child: Text(
                                                            "${element.flag} " +
                                                                element.name,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                        Text(
                                                          "+" +
                                                              element.dialCode,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) =>
                                                      const SizedBox(
                                                        height: 8,
                                                        child: Center(
                                                            child: Divider()),
                                                      ),
                                              itemCount:
                                                  searchedCountryList.length),
                                        );
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: context.width / 4,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    margin: EdgeInsets.only(
                      left: context.dProvider.textDirectionRight ? 0 : 6,
                      right: !context.dProvider.textDirectionRight ? 6 : 0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                          left: context.dProvider.textDirectionRight
                              ? BorderSide(
                                  color: context.color.primaryBorderColor,
                                  width: 2)
                              : BorderSide.none,
                          right: context.dProvider.textDirectionRight
                              ? BorderSide.none
                              : BorderSide(
                                  color: context.color.primaryBorderColor,
                                  width: 2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: phone,
                          builder: (context, value, child) => Text(
                              "${value?.flag.toString() ?? "🇧🇩"} +" +
                                  (phone.value?.dialCode ?? "880")),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: context.color.secondaryContrastColor,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            validator: (number) {
              if (number == null) {
                return lengthErrorText;
              }
              if ((value?.phoneLength is int) &&
                  number.length == value?.phoneLength) {
                return null;
              }
              if ((value?.phoneLength is int) &&
                  number.length < value?.phoneLength) {
                return lengthErrorText;
              }
              if (value == null) {
                return null;
              }
              int minLength = 1;
              value.phoneLength.forEach((element) {
                minLength = element < minLength ? element : minLength;
              });
              if (number.length < minLength) {
                return lengthErrorText;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  int phoneLength(Phone? phone) {
    int length = 1;
    if (phone == null) {
      return 10;
    }
    if (phone.phoneLength is int) {
      return phone.phoneLength;
    }
    if (phone.phoneLength is List) {
      phone.phoneLength.forEach((element) {
        length = element > length ? element : length;
      });
      return length;
    }
    return length;
  }

  loadCountries() async {
    var data = await rootBundle.loadString("assets/files/phones.json");
    List tempList = json.decode(data);
    for (var element in tempList) {
      countryList.add(Phone(
          name: element['label'],
          code: element["code"],
          dialCode: element['phone'],
          flag: element['flag'],
          phoneLength: element['phoneLength']));
    }
  }
}

class Phone {
  final String name;
  final code;
  final dialCode;
  final phoneLength;
  final flag;

  Phone({
    required this.name,
    this.code,
    this.dialCode,
    this.flag,
    this.phoneLength,
  });
}
