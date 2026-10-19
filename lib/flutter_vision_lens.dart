/// An interactive Apple Visual Intelligence and Google Lens style multimodal
/// camera and image overlay for Flutter with tap-to-inspect, freehand lasso,
/// glowing shaders, and pluggable AI adapters.
library flutter_vision_lens;

// Adapters
export 'src/adapters/gemini_vision_adapter.dart';
export 'src/adapters/mock_vision_adapter.dart';
export 'src/adapters/vision_ai_adapter.dart';

// Controllers
export 'src/controllers/vision_lens_controller.dart';

// Engine
export 'src/engine/vision_crop_engine.dart';

// Models
export 'src/models/vision_lens_mode.dart';
export 'src/models/vision_object.dart';
export 'src/models/vision_region.dart';
export 'src/models/vision_style.dart';

// Painters
export 'src/painters/glowing_border_painter.dart';
export 'src/painters/reticle_painter.dart';
export 'src/painters/spotlight_dimmer_painter.dart';

// Widgets
export 'src/widgets/vision_lens_overlay.dart';
export 'src/widgets/vision_lens_result_sheet.dart';
export 'src/widgets/vision_lens_toolbar.dart';
