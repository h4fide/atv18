import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SchedulerBinding.instance.platformDispatcher.onBeginFrame = null;
  SchedulerBinding.instance.platformDispatcher.onDrawFrame = null;
  
  runApp(const VFDSimulatorApp());
}

class VFDSimulatorApp extends StatelessWidget {
  const VFDSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VFD Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VFDSimulatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

enum DisplayMode { parameter, value, status }

const DEFAULT_PARAMETERS = {
  "rdY": {"value": "rdY", "readonly": true, "order": 0, "type": "status"},
  "FrH": {"value": 0.0, "min": 0.0, "max": 50.0, "readonly": true, "order": 1, "type": "status"},
  "LCr": {"value": 0.0, "min": 0.0, "max": 999.9, "readonly": true, "order": 2, "type": "status"},
  "rFr": {"value": 0.0, "min": 0.0, "max": 50.0, "readonly": true, "order": 3, "type": "status"},
  "ULn": {"value": 400, "min": 0.0, "max": 999.9, "readonly": true, "order": 4, "type": "status"},
  "FLt": {"value": "nErr", "readonly": true, "order": 23, "type": "status"},
  "bFr": {"value": 50.0, "min": 50.0, "max": 60.0, "default": 50.0, "order": 5, "type": "param"},
  "ACC": {"value": 3.0, "min": 0.0, "max": 3600.0, "default": 3.0, "order": 6, "type": "param"},
  "dEC": {"value": 3.0, "min": 0.0, "max": 3600.0, "default": 3.0, "order": 7, "type": "param"},
  "LSP": {"value": 5.0, "min": 0.0, "max": 50.0, "default": 0.0, "order": 8, "type": "param"},
  "HSP": {"value": 50.0, "min": 0.0, "max": 50.0, "default": 50.0, "order": 9, "type": "param"},
  "ItH": {"value": 0.0, "min": 0.0, "max": 1.15, "default": 1.0, "order": 11, "type": "param"},
  "JPF": {"value": 0.0, "min": 0.0, "max": 50.0, "default": 0.0, "order": 12, "type": "param"},
  "Idc": {"value": 0.7, "min": 0.0, "max": 1.15, "default": 0.7, "order": 13, "type": "param"},
  "tdc": {"value": 0.5, "min": 0.0, "max": 25.5, "default": 0.5, "order": 14, "type": "param"},
  "UFr": {"value": 20.0, "min": 0.0, "max": 100.0, "default": 20.0, "order": 15, "type": "param"},
  "SP3": {"value": 50.0, "min": 0.0, "max": 50.0, "default": 30.0, "order": 16, "type": "param"},
  "SP4": {"value": 33.3, "min": 0.0, "max": 50.0, "default": 25.0, "order": 17, "type": "param"},
  "JOG": {"value": 10.0, "min": 0.0, "max": 10.0, "default": 10.0, "order": 18, "type": "param"},
  "Fdt": {"value": 0.0, "min": 0.0, "max": 50.0, "default": 0.0, "order": 19, "type": "param"},
  "rPG": {"value": 1.0, "min": 0.01, "max": 100.0, "default": 1.0, "order": 20, "type": "param"},
  "rIG": {"value": 1.0, "min": 0.01, "max": 100.0, "default": 1.0, "order": 21, "type": "param"},
  "FbS": {"value": 1.0, "min": 0.1, "max": 100.0, "default": 1.0, "order": 22, "type": "param"},
};

class VFDSimulatorScreen extends StatefulWidget {
  const VFDSimulatorScreen({super.key});

  @override
  State<VFDSimulatorScreen> createState() => _VFDSimulatorScreenState();
}

class _VFDSimulatorScreenState extends State<VFDSimulatorScreen> with TickerProviderStateMixin {
  late AnimationController _motorController;
  late Ticker _ticker;
  double _rotationAngle = 0.0;
  String displayValue = "rdY";
  DisplayMode displayMode = DisplayMode.status;
  double currentSpeed = 0;
  double targetSpeed = 0;
  int direction = 0;
  bool li1 = false, li2 = false, li3 = false, li4 = false;
  late Map<String, dynamic> parameters;
  String currentParam = "rdY";
  bool editingValue = false;
  Timer? _motorUpdateTimer;
  Timer? _buttonRepeatTimer;
  int requestedDirection = 0;
  String? firstPressed;
  double angle = 0;
  DateTime? lastUpdateTime;
  bool _isFlashing = false;
  final Map<String, dynamic> _originalValues = {};
  double _lastTickTime = 0;

  @override
  void initState() {
    super.initState();
    _motorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    parameters = Map.fromEntries(
      DEFAULT_PARAMETERS.entries.map((e) => MapEntry(
        e.key,
        Map<String, dynamic>.from(e.value)
      ))
    );
    
    _ticker = createTicker((elapsed) {
      if (direction != 0 && currentSpeed > 0) {
        final now = elapsed.inMicroseconds / 1000000;
        final deltaTime = now - _lastTickTime;
        _lastTickTime = now;
        
        final rotationSpeed = currentSpeed * 2.0; 
        final rotationAmount = rotationSpeed * deltaTime * direction;
        
        setState(() {
          _rotationAngle += rotationAmount * math.pi;
          _rotationAngle = _rotationAngle % (2 * math.pi);
        });
      } else {
        _lastTickTime = elapsed.inMicroseconds / 1000000;
      }
    });
    
    _ticker.start();
    
    _motorUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _updateMotor());
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        parameters.forEach((key, param) {
          if (param['type'] == 'param') { 
            final savedValue = prefs.getString('param_complete_$key');
            if (savedValue != null) {
              final savedParam = Map<String, dynamic>.from(json.decode(savedValue));
              parameters[key] = savedParam;
            }
          }
        });

        li1 = prefs.getBool('li1') ?? false;
        li2 = prefs.getBool('li2') ?? false;
        li3 = prefs.getBool('li3') ?? false;
        li4 = prefs.getBool('li4') ?? false;
      });
    } catch (e) {
      debugPrint('Error loading values: $e');
      _resetToDefaults();
    }
  }

  Future<void> _saveValues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all editable parameters as complete JSON objects
      for (var entry in parameters.entries) {
        if (entry.value['type'] == 'param') {
          final jsonStr = json.encode(entry.value);
          await prefs.setString('param_complete_${entry.key}', jsonStr);
        }
      }

      // Save switch states
      await prefs.setBool('li1', li1);
      await prefs.setBool('li2', li2);
      await prefs.setBool('li3', li3);
      await prefs.setBool('li4', li4);

      debugPrint('Values saved successfully');
    } catch (e) {
      debugPrint('Error saving values: $e');
    }
  }

  void _resetToDefaults() {
    parameters = Map.fromEntries(
      DEFAULT_PARAMETERS.entries.map((e) => MapEntry(
        e.key,
        Map<String, dynamic>.from(e.value)
      ))
    );
  }

  @override
  Future<void> dispose() async {
    // Ensure values are saved before disposing
    await _saveValues();
    _ticker.dispose();
    _motorUpdateTimer?.cancel();
    _buttonRepeatTimer?.cancel();
    _motorController.dispose();
    super.dispose();
  }

  // Add utility methods for number handling
  double clamp(double value, double min, double max) {
    final absValue = value.abs(); 
    if (absValue < min) return min;
    if (absValue > max) return max;
    return absValue;
  }

  double roundToDecimal(double value, [int places = 1]) {
    double mod = math.pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  int get rpmSpeed => (currentSpeed * 60).round();


  void _updateMotor() {
    final now = DateTime.now();
    if (lastUpdateTime == null) {
      lastUpdateTime = now;
      return;
    }

    final dt = now.difference(lastUpdateTime!).inMilliseconds / 1000.0;
    lastUpdateTime = now;

    setState(() {
      if (currentSpeed != targetSpeed) {
        final baseFreq = parameters["bFr"]["value"].toDouble();
        
        if (targetSpeed == 0) {
          // Deceleration to stop
          final decTime = parameters["dEC"]["value"].toDouble();
          final rate = baseFreq / decTime;
          final maxSpeedChange = rate * dt;

          currentSpeed = clamp(
            currentSpeed - maxSpeedChange,
            0.0,
            parameters["HSP"]["value"].toDouble()
          );
        } else if (currentSpeed < targetSpeed) {
          // Acceleration
          final accTime = parameters["ACC"]["value"].toDouble();
          final rate = baseFreq / accTime;
          final maxSpeedChange = rate * dt;
          
          currentSpeed = clamp(
            currentSpeed + maxSpeedChange,
            0.0,
            targetSpeed // Limit to target speed instead of HSP
          );
        } else {
          // Deceleration
          final decTime = parameters["dEC"]["value"].toDouble();
          final rate = baseFreq / decTime;
          final maxSpeedChange = rate * dt;
          
          currentSpeed = clamp(
            currentSpeed - maxSpeedChange,
            targetSpeed, // Don't go below target speed
            parameters["HSP"]["value"].toDouble()
          );
        }

        currentSpeed = roundToDecimal(currentSpeed);

        // Handle direction change when speed reaches zero
        if (currentSpeed.abs() < 0.1) {
          currentSpeed = 0;
          if (requestedDirection != direction) {
            direction = requestedDirection;
          }
        }
      }

      // Update status parameters
      parameters["FrH"]["value"] = roundToDecimal(currentSpeed);
      parameters["rFr"]["value"] = roundToDecimal(currentSpeed * direction.abs());
    });
  }

  void _updateSpeed() {
    // Store previous direction for detecting direction changes
    final previousDirection = direction;
    
    // Determine requested direction from inputs
    if (firstPressed == 'LI1' && li1) {
      requestedDirection = 1;
    } else if (firstPressed == 'LI2' && li2) {
      requestedDirection = -1;
    } else if (li1 && !li2) {
      requestedDirection = 1;
    } else if (li2 && !li1) {
      requestedDirection = -1;
    } else {
      requestedDirection = 0;
    }

    // determine target speed based on LI3 and LI4
    double newTarget;
    if (!li3 && !li4) {
      newTarget = parameters["LSP"]["value"].toDouble();
    } else if (li3 && !li4) {
      newTarget = parameters["SP3"]["value"].toDouble();
    } else if (!li3 && li4) {
      newTarget = parameters["SP4"]["value"].toDouble();
    } else {
      newTarget = parameters["HSP"]["value"].toDouble();
    }

    setState(() {
      if (requestedDirection == 0) {
        // Stopping case
        targetSpeed = 0;
      } else if (requestedDirection != direction && direction != 0) {
        // Direction reversal case - first decelerate to 0
        targetSpeed = 0;
      } else if (currentSpeed == 0) {
        // Starting from stop - use LSP first
        targetSpeed = parameters["LSP"]["value"].toDouble();
        direction = requestedDirection;
      } else {
        // Normal operation - maintain current speed or adjust to new target
        targetSpeed = newTarget;
        direction = requestedDirection;
      }
    });
  }

  void _handleDirectionChange(String button) {
    if (firstPressed == null) {
      if ((button == 'LI1' && li1) || (button == 'LI2' && li2)) {
        firstPressed = button;
      }
    }
    if (!li1 && !li2) {
      firstPressed = null;
    }
    _updateSpeed();
  }

  void _updateTargetSpeed() {
    double newTarget;
    if (!li3 && !li4) {
      newTarget = parameters["LSP"]["value"].toDouble();
    } else if (li3 && !li4) {
      newTarget = parameters["SP3"]["value"].toDouble();
    } else if (!li3 && li4) {
      newTarget = parameters["SP4"]["value"].toDouble();
    } else {
      newTarget = parameters["HSP"]["value"].toDouble();
    }

    setState(() {
      if (direction != 0) {
        targetSpeed = newTarget;
      }
    });
  }

  // Add this new widget for the connected buttons
  Widget _buildConnectedButtons() {
    return Container(
      height: 56, 
      width: 115,  
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 231, 231),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: _downButton, 
              onLongPressStart: (_) {
                _buttonRepeatTimer = Timer.periodic(
                  const Duration(milliseconds: 100),
                  (_) => _downButton(), 
                );
              },
              onLongPressEnd: (_) {
                _buttonRepeatTimer?.cancel();
                _buttonRepeatTimer = null;
              },
            ),
            _buildCircularButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: _upButton, 
              onLongPressStart: (_) {
                _buttonRepeatTimer = Timer.periodic(
                  const Duration(milliseconds: 100),
                  (_) => _upButton(), 
                );
              },
              onLongPressEnd: (_) {
                _buttonRepeatTimer?.cancel();
                _buttonRepeatTimer = null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Function(LongPressStartDetails) onLongPressStart,
    required Function(LongPressEndDetails) onLongPressEnd,
  }) {
    return GestureDetector(
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF424242),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  the display value formatting
    final displayValueFormatted = _isFlashing ? "" : formatDisplayValue(
      editingValue ? parameters[currentParam]["value"] : displayValue
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Altivar 18 Simulator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // LCD Display
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF181317),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    displayValueFormatted,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 24,
                      color: Color(0xFFE33B3B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildConnectedButtons(),
                  const SizedBox(width: 18),
                  _buildCircularControlButton(
                    label: 'DATA',
                    onPressed: _dataButton,
                  ),
                  const SizedBox(width: 8),
                  _buildCircularControlButton(
                    label: 'ENT',
                    onPressed: _entButton,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Toggle Switches
              _buildToggleSwitches(),
              const SizedBox(height: 20),

                // Status Labels
                Text(
                'Speed: ${currentSpeed.toStringAsFixed(1)} Hz ($rpmSpeed RPM)',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16,
                ),
                ),
                Text(
                'Direction: ${_getDirectionText()}',
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16,
                ),
                ),
                const SizedBox(height: 20),

              // Motor Visualization with RepaintBoundary   
              RepaintBoundary(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: MotorPainter(rotationAngle: _rotationAngle),
                    isComplex: true, 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularControlButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      width: 48,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 66, 66, 66),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _upButton() {
    setState(() {
      if (editingValue) {
        final param = parameters[currentParam];
        //  check if parameter is readonly
        final isReadOnly = param["readonly"] as bool? ?? false;
        
        if (!isReadOnly) {
          //  convert value to double
          final currentValue = (param["value"] is num) 
              ? param["value"].toDouble()
              : double.tryParse(param["value"].toString()) ?? 0.0;
              
          final increment = currentValue < 100 ? 0.1 : 1.0;
          final min = (param["min"] as num?)?.toDouble() ?? 0.0;
          final max = (param["max"] as num?)?.toDouble() ?? 50.0;
          
          final newValue = clamp(
            roundToDecimal(currentValue + increment),
            min,
            max
          );
          
          param["value"] = newValue;
          displayValue = formatDisplayValue(newValue);
          displayMode = DisplayMode.value;
        }
      } else {
        // Parameter navigation mode
        final allParams = parameters.keys.toList()
          ..sort((a, b) => (parameters[a]["order"] as int).compareTo(parameters[b]["order"] as int));
        
        final currentIdx = allParams.indexOf(currentParam);
        currentParam = allParams[(currentIdx + 1) % allParams.length];
        displayMode = DisplayMode.parameter;
        displayValue = currentParam;
      }
    });
  }

  void _downButton() {
    setState(() {
      if (editingValue) {
        final param = parameters[currentParam];
        //  check if parameter is readonly
        final isReadOnly = param["readonly"] as bool? ?? false;
        
        if (!isReadOnly) {
          //  convert value to double
          final currentValue = (param["value"] is num) 
              ? param["value"].toDouble()
              : double.tryParse(param["value"].toString()) ?? 0.0;
              
          final decrement = currentValue < 100 ? 0.1 : 1.0;
          final min = (param["min"] as num?)?.toDouble() ?? 0.0;
          final max = (param["max"] as num?)?.toDouble() ?? 50.0;
          
          final newValue = clamp(
            roundToDecimal(currentValue - decrement),
            min,
            max
          );
          
          param["value"] = newValue;
          displayValue = formatDisplayValue(newValue);
          displayMode = DisplayMode.value;
        }
      } else {
        //  navigation mode
        final allParams = parameters.keys.toList()
          ..sort((a, b) => (parameters[a]["order"] as int).compareTo(parameters[b]["order"] as int));
        
        final currentIdx = allParams.indexOf(currentParam);
        currentParam = allParams[(currentIdx - 1 + allParams.length) % allParams.length];
        displayMode = DisplayMode.parameter;
        displayValue = currentParam;
      }
    });
  }

  // Remove _buildControlButton method that is not being used

  Widget _buildToggleSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }

  Widget _buildToggleSwitches() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggleSwitch('LI1', li1, (value) => setState(() {
              li1 = value;
              _handleDirectionChange('LI1');
              _saveValues();
            })),
            _buildToggleSwitch('LI2', li2, (value) => setState(() {
              li2 = value;
              _handleDirectionChange('LI2');
              _saveValues();
            })),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggleSwitch('LI3', li3, (value) => setState(() {
              li3 = value;
              _updateTargetSpeed();
              _saveValues();
            })),
            _buildToggleSwitch('LI4', li4, (value) => setState(() {
              li4 = value;
              _updateTargetSpeed();
              _saveValues();
            })),
          ],
        ),
      ],
    );
  }

  String _getDirectionText() {
    switch (direction) {
      case 1:
        return 'Forward';
      case -1:
        return 'Reverse';
      default:
        return 'Stopped';
    }
  }

  void _dataButton() {
    setState(() {
      if (!parameters.containsKey(currentParam)) return;
      
      final param = parameters[currentParam];
      final isReadOnly = param["readonly"] ?? false;
      
      if (isReadOnly) {
        // For readonly parameters, just toggle between parameter and value display
        if (displayMode == DisplayMode.parameter) {
          displayMode = DisplayMode.value;
          displayValue = formatDisplayValue(param["value"]);
        } else {
          displayMode = DisplayMode.parameter;
          displayValue = currentParam;
        }
        return;
      }
      
      // For editable parameters
      if (editingValue) {
        
        editingValue = false;
        displayMode = DisplayMode.parameter;
        // Restore original value
        if (_originalValues.containsKey(currentParam)) {
          param["value"] = _originalValues[currentParam];
          _originalValues.remove(currentParam);
        }
        displayValue = currentParam;
      } else {
        // Enter edit mode
        editingValue = true;
        displayMode = DisplayMode.value;
        // Store original value
        _originalValues[currentParam] = param["value"];
        displayValue = formatDisplayValue(param["value"]);
      }
    });
  }

  // Add parameter validation method
  void _validateParameterValue(String paramName, dynamic value) {
    final param = parameters[paramName];
    if (param == null) return;

    double newValue = value is double ? value.abs() : double.tryParse(value.toString())?.abs() ?? 0.0;
    
    switch (paramName) {
      case "LSP":
        // LSP cannot be higher than HSP and must be non-negative
        newValue = clamp(newValue, 0.0, parameters["HSP"]["value"]);
        param["value"] = roundToDecimal(newValue);
        
        // Adjust dependent parameters if needed
        _adjustDependentSpeeds("SP3", newValue, parameters["HSP"]["value"]);
        _adjustDependentSpeeds("SP4", newValue, parameters["HSP"]["value"]);
        _saveValues();  
        break;
        
      case "HSP":
        // HSP cannot be lower than LSP and must be non-negative
        newValue = clamp(newValue, parameters["LSP"]["value"], param["max"]);
        param["value"] = roundToDecimal(newValue);
        
        // Adjust dependent parameters if needed
        _adjustDependentSpeeds("SP3", parameters["LSP"]["value"], newValue);
        _adjustDependentSpeeds("SP4", parameters["LSP"]["value"], newValue);
        _saveValues();  
        break;
        
      case "SP3":
      case "SP4":
        // Preset speeds must stay between LSP and HSP and be non-negative
        newValue = clamp(newValue, 
          parameters["LSP"]["value"], 
          parameters["HSP"]["value"]
        );
        param["value"] = roundToDecimal(newValue);
        _saveValues();  
        break;

      case "ACC":
      case "dEC":
        // Acceleration and deceleration times must be positive
        newValue = clamp(newValue, 0.1, param["max"]);
        param["value"] = roundToDecimal(newValue);
        _saveValues();  
        break;
        
      case "rPG":
      case "rIG":
      case "FbS":
        // PID parameters must be positive
        newValue = clamp(newValue, param["min"], param["max"]);
        param["value"] = roundToDecimal(newValue);
        _saveValues();  
        break;
        
      default:
        // Ensure all other parameters are non-negative
        newValue = clamp(newValue.abs(), param["min"], param["max"]);
        param["value"] = roundToDecimal(newValue);
        _saveValues();  
    }
  }

  // Add helper method for adjusting dependent speed parameters
  void _adjustDependentSpeeds(String paramName, double minValue, double maxValue) {
    if (!parameters.containsKey(paramName)) return;
    
    final param = parameters[paramName];
    double currentValue = param["value"];
    
    if (currentValue < minValue) {
      param["value"] = roundToDecimal(minValue);
    } else if (currentValue > maxValue) {
      param["value"] = roundToDecimal(maxValue);
    }
  }

  //  parameter validation
  void _entButton() {
    setState(() {
      if (!parameters.containsKey(currentParam)) return;
      
      final param = parameters[currentParam];
      final isReadOnly = param["readonly"] ?? false;

      if (editingValue && !isReadOnly) {
        _validateParameterValue(currentParam, param["value"]);
        _originalValues.remove(currentParam);
        _flashDisplay();
        _updateSpeed();
        displayValue = formatDisplayValue(param["value"]);
        _saveValues(); 
        editingValue = false;
      } else {
        editingValue = false;
        displayMode = DisplayMode.parameter;
        displayValue = currentParam;
      }
    });
  }

  void _flashDisplay() {
    if (_isFlashing) return;
    _isFlashing = true;
    displayValue = "";
    
    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        _isFlashing = false;
        if (editingValue) {
          displayValue = parameters[currentParam]["value"].toString();
        } else {
          displayValue = currentParam;
        }
      });
    });
  }


  String formatDisplayValue(dynamic value) {
    if (value == null) return "0.0";
    if (value is num) {
      return roundToDecimal(value.abs().toDouble()).toString();
    }
    if (value is String && value.isNotEmpty) {
      try {
        return roundToDecimal(double.parse(value).abs()).toString();
      } catch (e) {
        return value;
      }
    }
    return value.toString();
  }

  double getParameterValue(String paramName) {
    try {
      final param = parameters[paramName];
      if (param == null) return 0.0;
      
      final value = param["value"];
      if (value == null) return 0.0;
      
      final doubleValue = value is String ? double.parse(value) : value.toDouble();
      return doubleValue.abs(); 
    } catch (e) {
      return 0.0;
    }
  }

  bool isValidNumber(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class MotorPainter extends CustomPainter {
  final double rotationAngle;

  MotorPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    final radius = math.min(size.width, size.height) / 2 - 10;


    canvas.drawCircle(Offset.zero, radius, paint);

    paint.strokeWidth = 2.5;
    paint.strokeCap = StrokeCap.round;
    
    for (int i = 0; i < 3; i++) {
      final angle = rotationAngle + (i * 2 * math.pi / 3);
      final x = radius * 0.8 * math.cos(angle);
      final y = radius * 0.8 * math.sin(angle);
      canvas.drawLine(Offset.zero, Offset(x, y), paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(MotorPainter oldDelegate) => 
    rotationAngle != oldDelegate.rotationAngle;
}
