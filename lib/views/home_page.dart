import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lista_tarefas/helpers/task_helper.dart';
import 'package:lista_tarefas/models/task.dart';
import 'package:lista_tarefas/views/task_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> _taskList = [];
  TaskHelper _helper = TaskHelper();
  bool _loading = true;
  bool _loading2 = true;
  double _lenghtBD;
  double _percentIsDone;

  @override
  void initState() {
    super.initState();
    _helper.getAll().then((list) {
      setState(() {
        _taskList = list;
        _loading = false;
      });
    });
    _helper.getCount().then((data) {
      setState(() {
        _lenghtBD = double.parse(data.toString());
      });
    });
    _helper.getIsDone().then((data) {
      setState(() {
        double x = double.parse(data.toString());
        _percentIsDone = x / _lenghtBD;
        _loading2 = false;
      });
    });
  }

  void updateLinearPercent() async {
    int x = await _helper.getCount();
    int y = await _helper.getIsDone();
    setState(() {
      _percentIsDone = double.parse(y.toString()) / double.parse(x.toString());
      //print(" %$_percentIsDone");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Lista de Tarefas'),
          actions: <Widget>[_buildLinearPercent()]),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: _addNewTask),
      body: _buildTaskList(),
    );
  }

  Widget _buildLinearPercent() {
    if (_loading2) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Padding(
        child: LinearPercentIndicator(
          width: 140.0,
          lineHeight: 14.0,
          percent: _percentIsDone,
          backgroundColor: Colors.grey,
          progressColor: Colors.red,
        ),
        padding: const EdgeInsets.all(8.0),
      );
    }
  }

  Widget _buildTaskList() {
    if (_taskList.isEmpty) {
      return Center(
        child: _loading ? CircularProgressIndicator() : Text("Sem tarefas!"),
      );
    } else {
      return ListView.separated(
        itemBuilder: _buildTaskItemSlidable,
        itemCount: _taskList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
      );
    }
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final task = _taskList[index];
    return CheckboxListTile(
      value: task.isDone,
      title: Text(task.title),
      subtitle: Text(task.description),
      onChanged: (bool isChecked) async {
        setState(() {
          task.isDone = isChecked;
        });
        _helper.update(task);
        updateLinearPercent();
      },
    );
  }

  Widget _buildTaskItemSlidable(BuildContext context, int index) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTaskItem(context, index),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Editar',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            _addNewTask(editedTask: _taskList[index], index: index);
          },
        ),
        IconSlideAction(
          caption: 'Excluir',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deleteTask(deletedTask: _taskList[index], index: index);
          },
        ),
      ],
    );
  }

  Future _addNewTask({Task editedTask, int index}) async {
    final task = await showDialog<Task>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TaskDialog(task: editedTask);
      },
    );

    if (task != null) {
      setState(() {
        if (index == null) {
          _taskList.add(task);
          _helper.save(task);
        } else {
          _taskList[index] = task;
          _helper.update(task);
        }
        updateLinearPercent();
      });
    }
  }

  void _deleteTask({Task deletedTask, int index}) {
    setState(() {
      _taskList.removeAt(index);
    });

    _helper.delete(deletedTask.id);

    Flushbar(
      title: "Exclusão de tarefas",
      message: "Tarefa \"${deletedTask.title}\" removida.",
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      duration: Duration(seconds: 3),
      mainButton: FlatButton(
        child: Text(
          "Desfazer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          setState(() {
            _taskList.insert(index, deletedTask);
            _helper.update(deletedTask);
          });
        },
      ),
    )..show(context);
  }
}
