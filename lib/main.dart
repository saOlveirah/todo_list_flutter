import 'package:flutter/material.dart';
import 'widgets/task_imput.dart';

void main(){
  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build (BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tarefas'),
        ),
        body: const Center(
          child: Text('Minhas tarefas aparecerão aqui!!!'),
        ),
        bottomNavigationBar: TaskInput(
          selectDate: DateTime.now(),
           onAdd: (title, date){
            debugPrint('Tarefa: $title');
            debugPrint('Data: $date');
           }
           ),
      ),
    );
  }
}