import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/plot/plot_export.dart';
import 'package:free_clac/services/plot_file_saver.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 导出写进相册目录', (tester) async {
    final saved = await savePlotExportFile(
      PlotExportFile(
        fileName: 'plot-clac-test.png',
        bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        mimeType: 'image/png',
      ),
    );
    // ignore: avoid_print
    print(
      'SAVED location=${saved.location} display=${saved.displayPath} '
      'canReveal=${saved.canReveal} note=${plotSaveLocationNote()}',
    );
    expect(saved.displayPath, startsWith('Pictures/free-clac'));
    expect(saved.canReveal, isFalse);

    final svg = await savePlotExportFile(
      PlotExportFile(
        fileName: 'plot-clac-test.svg',
        bytes: Uint8List.fromList('<svg/>'.codeUnits),
        mimeType: 'image/svg+xml',
      ),
    );
    // ignore: avoid_print
    print('SAVED svg location=${svg.location} display=${svg.displayPath}');
    expect(svg.displayPath, startsWith('Download/free-clac'));
  });
}
