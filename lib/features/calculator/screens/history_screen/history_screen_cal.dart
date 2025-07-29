import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<HistoryItem> historyItems = [
    // Ejemplo de datos
    HistoryItem(expression: "2 + 2", result: "4", date: "2025-07-28"),
    HistoryItem(expression: "5 * 3", result: "15", date: "2025-07-27"),
  ];
  List<HistoryItem> filteredItems = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    filteredItems = List.from(historyItems);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Calculation History',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.white),
          onPressed: _showClearDialog,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSearchBar(),
          SizedBox(height: 16),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: filteredItems.length,
              itemBuilder: (context, index, animation) {
                return _buildHistoryItem(
                  filteredItems[index],
                  animation,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search history...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: TextStyle(color: Colors.white),
        onChanged: (query) => _filterHistory(query),
      ),
    );
  }

  void _filterHistory(String query) {
    setState(() {
      filteredItems =
          historyItems
              .where(
                (item) =>
                    item.expression.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    item.result.toLowerCase().contains(query.toLowerCase()) ||
                    item.date.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Widget _buildHistoryItem(
    HistoryItem item,
    Animation<double> animation,
    int index,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: EdgeInsets.only(bottom: 12),
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _useHistoryItem(item),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.expression,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '= ${item.result}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.date,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.content_copy, size: 18),
                            color: Colors.grey[500],
                            onPressed: () => _copyToClipboard(item.result),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18),
                            color: Colors.grey[500],
                            onPressed: () => _deleteItem(index),
                          ),
                        ],
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

  void _deleteItem(int index) {
    final removedItem = filteredItems.removeAt(index);
    final originalIndex = historyItems.indexOf(removedItem);
    historyItems.removeAt(originalIndex);

    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: Duration(milliseconds: 300),
    );
    setState(() {});
  }

  Widget _buildRemovedItem(HistoryItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.red.withOpacity(0.1),
        margin: EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(item.expression, style: TextStyle(color: Colors.grey)),
          subtitle: Text(
            '= ${item.result}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void addNewHistoryItem(HistoryItem newItem) {
    historyItems.insert(0, newItem);
    filteredItems = List.from(historyItems);
    _listKey.currentState!.insertItem(0);
    setState(() {});
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied to clipboard')));
  }

  void _useHistoryItem(HistoryItem item) {
    // Aquí puedes implementar la lógica para reutilizar el historial
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Clear History'),
            content: Text('Are you sure you want to clear all history?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Clear'),
                onPressed: () {
                  setState(() {
                    historyItems.clear();
                    filteredItems.clear();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }
}
