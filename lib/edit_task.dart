import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'custom_widgets.dart';
import 'custom_functions.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, this.editTask});

  final Task? editTask;

  @override
  State<EditPage> createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  late DateTimeRange? _taskDateRange = widget.editTask == null
      ? null
      : DateTimeRange(start: widget.editTask!.start, end: widget.editTask!.end);
  late String _taskName = widget.editTask?.name ?? "";
  late String _taskDetail = widget.editTask?.detail ?? "";
  late Color _taskColor = widget.editTask?.color ?? withNewHue(theme(context).primary, 0);
  late bool _isTaskHomework = widget.editTask?.isHomework ?? false;
  late int? _taskTotalPages = widget.editTask?.totalPages;
  late double? _taskDifficulty = widget.editTask?.difficulty?.toDouble();
  bool isEdited = false;

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('yyyy/MM/dd(E)', Localizations.localeOf(context).toString());

    final formKey = GlobalKey<FormState>();

    Future pickDateRange(BuildContext context) async {
      final DateTimeRange initialDateRange = _taskDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 1)),
          );

      final DateTimeRange? newDateRange = await showDateRangePicker(
        context: context,
        initialDateRange: initialDateRange,
        firstDate: DateTime.utc(2010, 1, 1),
        lastDate: DateTime.utc(9999, 12, 31),
        locale: Localizations.localeOf(context),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context),
            child: child!,
          );
        },
      );
      if (newDateRange != null) {
        setState(() => _taskDateRange = newDateRange);
      } else {
        return;
      }
    }

    void confirmCancel(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("確認"),
            content: const Text("本当にやめますか？\n入力した内容は保存されません。"),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme(context).error,
                ),
                child: const Text("やめる"),
                onPressed: () {
                  Vibration.vibrate(duration: 10);
                  Navigator.pop(context);
                  Navigator.popUntil(
                    context,
                    (Route<dynamic> route) => route.isFirst,
                  );
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme(context).onBackground,
                ),
                child: const Text("やめない"),
                onPressed: () {
                  Vibration.vibrate(duration: 10);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (isEdited) {
          confirmCancel(context);
        } else {
          Navigator.popUntil(
            context,
            (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: _taskColor,
          foregroundColor: theme(context).onPrimary,
          title: const Text("タスクの追加/編集"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CustomMargin(height: 20),
                  CustomTextField(
                    initialValue: _taskName,
                    hintText: "タスクの名前を入力",
                    textStyle: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    ),
                    borderColor: _taskColor,
                    isUnderline: true,
                    isTextAlignCenter: true,
                    onChanged: (value) {
                      isEdited = true;
                      _taskName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "タスクの名前を入力してください。";
                      }
                      return null;
                    },
                  ),
                  const CustomMargin(height: 30),
                  CustomTextField(
                    initialValue: _taskDetail,
                    isMultiline: true,
                    borderColor: _taskColor,
                    isUnderline: false,
                    hintText: "くわしく\n\n\n\n\n",
                    onChanged: (value) {
                      isEdited = true;
                      _taskDetail = value;
                    },
                  ),
                  const CustomMargin(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("宿題モード"),
                      Switch(
                        value: _isTaskHomework,
                        onChanged: (value) {
                          isEdited = true;
                          setState(() => _isTaskHomework = value);
                        },
                      ),
                    ],
                  ),
                  if (_isTaskHomework)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("大変度"),
                            Slider(
                              value: _taskDifficulty ?? 5.0,
                              label: (_taskDifficulty ?? 5.0).round().toString(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              onChanged: (value) {
                                isEdited = true;
                                setState(() => _taskDifficulty = value);
                              },
                            ),
                          ],
                        ),
                        CustomTextField(
                          initialValue: (_taskTotalPages ?? "").toString(),
                          isNumber: true,
                          borderColor: _taskColor,
                          isUnderline: false,
                          hintText: "合計ページ数",
                          onChanged: (value) {
                            isEdited = true;
                            _taskTotalPages = int.tryParse(value);
                          },
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return "合計ページ数を入力してください。";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  const CustomMargin(height: 10),
                  CustomElevatedButton(
                    label: _taskDateRange == null
                        ? "期間を決める"
                        : "${formatter.format(_taskDateRange!.start)} ～ ${formatter.format(_taskDateRange!.end)}",
                    color: theme(context).tertiary,
                    textColor: theme(context).onTertiary,
                    isRoundedSquare: true,
                    width: 300,
                    onPressed: () {
                      isEdited = true;
                      Vibration.vibrate(duration: 10);
                      pickDateRange(context);
                    },
                  ),
                  const CustomMargin(height: 10),
                  CustomElevatedButton(
                    label: "色を決める",
                    color: theme(context).tertiary,
                    textColor: theme(context).onTertiary,
                    isRoundedSquare: true,
                    width: 300,
                    onPressed: () {
                      isEdited = true;
                      Vibration.vibrate(duration: 10);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("色を選んでください"),
                            content: SingleChildScrollView(
                              child: ClipRect(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: 0.36,
                                  child: BlockPicker(
                                    pickerColor: _taskColor,
                                    onColorChanged: (color) {
                                      setState(() {
                                        _taskColor = color;
                                      });
                                    },
                                    availableColors: [
                                      for (double i = 0; i < 8; i++)
                                        withNewHue(theme(context).primary, 45 * i),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("決定"),
                                onPressed: () {
                                  Vibration.vibrate(duration: 10);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const CustomMargin(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        label: "決定！",
                        color: _taskColor,
                        textColor: theme(context).onPrimary,
                        isRoundedSquare: false,
                        onPressed: () {
                          Vibration.vibrate(duration: 10);
                          if (formKey.currentState!.validate()) {
                            if (_taskDateRange == null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("確認"),
                                    content: const Text("期間を決めてください。"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("わかった"),
                                        onPressed: () {
                                          Vibration.vibrate(duration: 10);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
                            Task(
                              id: widget.editTask?.id,
                              isHomework: _isTaskHomework,
                              difficulty: _taskDifficulty?.round() ?? (_isTaskHomework ? 5 : null),
                              totalPages: _taskTotalPages,
                              name: _taskName,
                              detail: _taskDetail,
                              start: _taskDateRange!.start,
                              end: _taskDateRange!.end,
                              color: _taskColor,
                            ).insert();
                            Navigator.popUntil(
                              context,
                              (Route<dynamic> route) => route.isFirst,
                            );
                          }
                        },
                      ),
                      const CustomMargin(width: 10),
                      CustomElevatedButton(
                        label: "やっぱやめる",
                        color: theme(context).tertiary,
                        textColor: theme(context).onTertiary,
                        isRoundedSquare: false,
                        onPressed: () {
                          Vibration.vibrate(duration: 10);
                          if (isEdited) {
                            confirmCancel(context);
                          } else {
                            Navigator.popUntil(
                              context,
                              (Route<dynamic> route) => route.isFirst,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
