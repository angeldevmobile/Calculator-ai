import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart' as math_exp;
import 'package:flutter/scheduler.dart';

import '../../../../models/particle.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _expression = '';
  String _result = '0';
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isDarkMode = false;
  late List<Particle> _particles;
  late Ticker _particleTicker;

  final List<String> buttons = [
    'C',
    '⌫',
    '%',
    '/',
    '7',
    '8',
    '9',
    '×',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '=',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Inicializar partículas para el fondo animado
    _particles = List.generate(30, (index) => Particle(_isDarkMode));

    // Actualizar partículas cada frame usando Ticker
    _particleTicker = Ticker((_) {
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
      });
    });
    _particleTicker.start();

    // Mantén el listener del controller solo para la animación de botones
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleTicker.dispose();
    super.dispose();
  }

  void _buttonPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
        _result = '0';
      } else if (text == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (text == '=') {
        _calculateResult();
      } else {
        _expression += text;
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // Actualizar colores de las partículas
      for (var particle in _particles) {
        particle.isDarkMode = _isDarkMode;
      }
    });
  }

  void _calculateResult() {
    try {
      if (_expression.isEmpty) return;

      String expr = _expression.replaceAll('×', '*');
      final parser = math_exp.ShuntingYardParser();
      final exp = parser.parse(expr);
      final cm = math_exp.ContextModel();

      final eval = exp.evaluate(math_exp.EvaluationType.REAL, cm);

      _result =
          eval % 1 == 0 ? eval.toInt().toString() : eval.toStringAsFixed(4);
    } catch (e) {
      _result = 'Error';
    }
  }

  Widget _buildButton(String btnText, BuildContext context) {
    final isOperator = ['/', '×', '-', '+', '=', '%'].contains(btnText);
    final isSpecial = ['C', '⌫'].contains(btnText);

    Color textColor;
    if (isSpecial) {
      textColor = Colors.orangeAccent;
    } else if (isOperator) {
      textColor = Colors.blueAccent;
    } else {
      textColor = _isDarkMode ? Colors.white : Colors.black;
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _buttonPressed(btnText);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isOperator || isSpecial
                      ? textColor.withOpacity(0.5)
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              if (isOperator || isSpecial)
                BoxShadow(
                  color: textColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: Text(
              btnText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: textColor,
                shadows: [
                  if (isOperator || isSpecial)
                    Shadow(color: textColor.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado con partículas
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color:
                  _isDarkMode ? Colors.grey.shade900 : Colors.blueGrey.shade50,
            ),
            child: CustomPaint(
              painter: ParticlePainter(_particles),
              size: Size.infinite,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar con botón de tema
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: _toggleTheme,
                      ),
                    ],
                  ),
                ),

                // Display
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            _expression.isEmpty ? '' : _expression,
                            key: ValueKey(_expression),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 36,
                              color:
                                  _isDarkMode ? Colors.white70 : Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (child, anim) => FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: anim,
                                  child: child,
                                ),
                              ),
                          child: Text(
                            _result,
                            key: ValueKey(_result),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode ? Colors.white : Colors.black,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Teclado
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          _isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      child: BackdropFilter(
                        filter:
                            _isDarkMode
                                ? ColorFilter.mode(
                                  Colors.black.withOpacity(0.7),
                                  BlendMode.darken,
                                )
                                : ColorFilter.mode(
                                  Colors.white.withOpacity(0.7),
                                  BlendMode.lighten,
                                ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: buttons.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.1,
                                ),
                            itemBuilder: (context, index) {
                              return _buildButton(buttons[index], context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
