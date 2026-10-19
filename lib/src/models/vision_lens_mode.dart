/// The interaction mode currently active in the vision lens.
enum VisionLensMode {
  /// The lens is inactive or waiting for user interaction.
  idle,

  /// Tap an object or location to trigger a smart focus reticle.
  tapInspect,

  /// Draw a freehand lasso/loop around any object or text.
  lasso,

  /// Drag to create and adjust a rectangular bounding box.
  boundingBox,

  /// Automatically render bounding highlights for detected objects.
  autoDetect,
}
