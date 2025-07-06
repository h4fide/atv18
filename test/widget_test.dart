
import 'package:flutter_test/flutter_test.dart';
import 'package:atv18/main.dart';

void main() {
  testWidgets('VFD simulator test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VFDSimulatorApp());

    // Verify initial state
    expect(find.text('rdY'), findsOneWidget);
    expect(find.text('Speed: 0.0 Hz (0 RPM)'), findsOneWidget);
    expect(find.text('Direction: Stopped'), findsOneWidget);
    
    // Verify UI elements exist
    expect(find.text('DATA'), findsOneWidget);
    expect(find.text('ENT'), findsOneWidget);
    expect(find.text('LI1'), findsOneWidget);
    expect(find.text('LI2'), findsOneWidget);
    expect(find.text('LI3'), findsOneWidget);
    expect(find.text('LI4'), findsOneWidget);
  });
}
