/// Video Aspect Ratio scaling modes.
enum VideoAspectMode {
  fit, // Letterbox / Pillarbox
  fill, // Crop to screen
  original, // 1:1 pixel exact
  ratio16x9, // Stretched / fitted to 16:9
  ratio21x9, // Cinematic ultrawide
}
