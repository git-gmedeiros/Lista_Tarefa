import 'package:flutter/material.dart';
import 'package:lista_tarefas/models/task.dart';


class TaskDialog extends StatefulWidget {
  final Task task;

  TaskDialog({this.task});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priorityController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Task _currentTask = Task();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _currentTask = Task.fromMap(widget.task.toMap());
    }

    _titleController.text = _currentTask.title;
    _descriptionController.text = _currentTask.description;
    _priorityController.text = _currentTask.priority;
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.clear();
    _descriptionController.clear();
    _priorityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefas'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
              autofocus: true,
              validator: (text) {
                return text.isEmpty ? "Insira o titulo!" : null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrição'),
              validator: (text) {
                return text.isEmpty ? "Insira a descrição!" : null;
              },
            ),
            TextFormField(
              controller: _priorityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Prioridade'),
              validator: (text) {
                return text.isEmpty ? "Insira a prioridade!" : null;
              },
            )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _currentTask.title = _titleController.value.text;
              _currentTask.description = _descriptionController.text;
              _currentTask.priority = _priorityController.text;

              Navigator.of(context).pop(_currentTask);
            }
          },
        ),
      ],
    );
  }
}
