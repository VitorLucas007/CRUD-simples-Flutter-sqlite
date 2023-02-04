import 'package:app_teste_sqlite/data/slq_helper_dart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Todos os Dados
  List<Map<String, dynamic>> _list = [];

  bool _isLoading = true;
  //Esta função é usada para buscar todos os dados do banco de dados
  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _list = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Carregando o diário quando o aplicativo é iniciado
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  
// Esta função será acionada quando o botão flutuante for pressionado
// Também será acionado quando você quiser atualizar um item
void _showForm(int ? id) async {
  if (id != null) {
    // id == null - cria novo item
    // id != null - atualiza um item existente
    final existingItem = 
        _list.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descriptionController.text = existingItem['description'];
  }

  showModalBottomSheet(
    context: context, 
    elevation: 5,
    isScrollControlled: true,
    builder: (_) => Container(
      padding: EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
        // isso evitará que o teclado programável cubra os campos de texto
        bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              // Salva um novo Item
              if (id == null){
                await _addItem();
              }
              if (id != null) {
                await _updateItem(id);
              }
              // Limpa os campos de texto
              _titleController.text = '';
              _descriptionController.text = '';

              // Fecha a planilha inferior
              Navigator.of(context).pop();
              }, 
            child: Text(id == null ? 'Create New': 'Update'),
            )
        ],
      ),
    ));
}

// Insere um novo diário no banco de dados
Future<void> _addItem() async {
  await SQLHelper.createItem(
    _titleController.text, _descriptionController.text);
    _refreshItems();
}


// Atualiza um item existente
Future<void> _updateItem(int id) async {
  await SQLHelper.updateItem(
    id, _titleController.text, _descriptionController.text);
  _refreshItems();
}

// Deletando um item
void _deletItem(int id) async {
  await SQLHelper.deleteItem(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Sucesso em apagar o item')
    ));
    _refreshItems();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Livros'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) => Card(
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_list[index]['title']),
              subtitle: Text(_list[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
        // IconButton para atualizar
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_list[index]['id']),
                      ),
        // IconButton para deletar
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                                _deletItem(_list[index]['id']), 
                        ),
                  ],
                ),
              )),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add,),
          backgroundColor: Colors.deepOrange,
          onPressed: () => _showForm(null),
        ),
    );
  }
}