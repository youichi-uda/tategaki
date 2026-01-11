/// A comprehensive Flutter package for Japanese vertical text (tategaki) layout
/// with advanced typography features.
library;

// Widgets
export 'src/widgets/vertical_text.dart';
export 'src/widgets/selectable_vertical_text.dart';
export 'src/widgets/selection_area_vertical_text.dart';
export 'src/widgets/vertical_rich_text.dart';

// Models
export 'src/models/vertical_text_style.dart';
export 'src/models/ruby_text.dart';
export 'src/models/kenten.dart';
export 'src/models/tatechuyoko.dart';
export 'src/models/warichu.dart';
export 'src/models/figure.dart';
export 'src/models/vertical_text_span.dart';
export 'src/models/text_decoration.dart';
export 'src/models/gaiji.dart';

// Utils (for advanced usage)
export 'src/utils/rotation_rules.dart';
export 'src/utils/kenten_renderer.dart';
export 'src/utils/warichu_renderer.dart';
export 'src/utils/decoration_renderer.dart';
export 'src/utils/tatechuyoko_detector.dart';
export 'src/utils/figure_layouter.dart';
export 'src/utils/gaiji_renderer.dart';

// Re-export kinsoku package for backward compatibility and convenience
export 'package:kinsoku/kinsoku.dart';
