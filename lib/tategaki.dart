/// A comprehensive Flutter package for Japanese vertical text (tategaki) layout
/// with advanced typography features.
library tategaki;

// Widgets
export 'src/widgets/vertical_text.dart';
export 'src/widgets/vertical_rich_text.dart';

// Models
export 'src/models/vertical_text_style.dart';
export 'src/models/ruby_text.dart';
export 'src/models/kenten.dart';
export 'src/models/tatechuyoko.dart';
export 'src/models/figure.dart';
export 'src/models/vertical_text_span.dart';

// Utils (for advanced usage)
export 'src/utils/character_classifier.dart';
export 'src/utils/rotation_rules.dart';
export 'src/utils/yakumono_adjuster.dart';
export 'src/utils/kenten_renderer.dart';
export 'src/utils/tatechuyoko_detector.dart';
export 'src/utils/kinsoku_processor.dart';
export 'src/utils/kerning_processor.dart';
export 'src/utils/figure_layouter.dart';
