import 'package:flutter/material.dart';

class AISolverScreen extends StatefulWidget {
  const AISolverScreen({super.key});

  @override
  State<AISolverScreen> createState() => _AISolverScreenState();
}

class _AISolverScreenState extends State<AISolverScreen> {
  final TextEditingController _controller = TextEditingController();
  String _aiResult = "";

  void _solveEquation() {
    setState(() {
      // Simulación temporal de respuesta AI
      _aiResult =
          "Explicación paso a paso:\n\n1. Interpretar la ecuación\n2. Aplicar operaciones básicas\n3. Resultado final: 42";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "AI Solver",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // Campo de entrada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Escribe una ecuación o problema...",
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón de resolver
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.psychology, color: Colors.white),
                label: const Text(
                  "Resolver con AI",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: _solveEquation,
              ),
            ),

            const SizedBox(height: 20),

            // Resultado AI animado
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                    _aiResult.isNotEmpty
                        ? Container(
                          key: ValueKey(_aiResult),
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            _aiResult,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
