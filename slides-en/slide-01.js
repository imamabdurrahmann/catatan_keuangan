/**
 * Slide 01: Cover Page - Personal Finance Tracker
 * Exports createSlide(pres, theme)
 */
function createSlide(pres, theme) {
  const slide = pres.addSlide();

  // --- Background ---
  slide.background = { color: theme.bg };

  // --- Left accent bar (asymmetric element) ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 0.18, h: 5.625,
    fill: { color: theme.primary }
  });

  // --- Secondary thin stripe ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.18, y: 0, w: 0.06, h: 5.625,
    fill: { color: theme.accent }
  });

  // --- Decorative circle top-right ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 7.8, y: -0.8, w: 3.0, h: 3.0,
    fill: { color: theme.light, transparency: 50 }
  });

  // --- Decorative circle bottom-right ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 8.5, y: 4.2, w: 2.0, h: 2.0,
    fill: { color: theme.accent, transparency: 60 }
  });

  // --- Small decorative dot cluster ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 0.6, y: 4.5, w: 0.15, h: 0.15,
    fill: { color: theme.accent }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 0.85, y: 4.65, w: 0.1, h: 0.1,
    fill: { color: theme.light }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 1.0, y: 4.35, w: 0.12, h: 0.12,
    fill: { color: theme.secondary }
  });

  // --- Main title ---
  slide.addText("Personal Finance Tracker", {
    x: 0.6, y: 1.6, w: 8.5, h: 1.2,
    fontFace: "Georgia",
    fontSize: 52,
    color: theme.primary,
    bold: true
  });

  // --- Subtitle ---
  slide.addText("Personal Financial Management App", {
    x: 0.6, y: 2.75, w: 8.0, h: 0.6,
    fontFace: "Calibri",
    fontSize: 22,
    color: theme.secondary
  });

  // --- Divider line ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.6, y: 3.45, w: 3.5, h: 0.04,
    fill: { color: theme.accent }
  });

  // --- Tagline ---
  slide.addText("Manage your finances with ease and security", {
    x: 0.6, y: 3.65, w: 7.0, h: 0.5,
    fontFace: "Calibri",
    fontSize: 16,
    color: theme.accent,
    italic: true
  });

  // --- Date badge ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.6, y: 4.5, w: 1.5, h: 0.45,
    fill: { color: theme.primary, transparency: 15 },
    line: { color: theme.primary, width: 1 }
  });
  slide.addText("April 2026", {
    x: 0.6, y: 4.5, w: 1.5, h: 0.45,
    fontFace: "Calibri",
    fontSize: 13,
    color: theme.primary,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // --- NO page number badge on cover ---
}

// --- Standalone preview ---
if (typeof require !== "undefined") {
  const PptxGenJS = require("pptxgenjs");
  const path = require("path");

  const theme = {
    primary: "2E7D32",
    secondary: "388E3C",
    accent: "66BB6A",
    light: "A5D6A7",
    bg: "F1F8E9"
  };

  const pres = new PptxGenJS();
  pres.layout = "LAYOUT_16x9";
  pres.defineLayout({ name: "CUSTOM", width: 10, height: 5.625 });
  pres.layout = "CUSTOM";

  createSlide(pres, theme);

  pres.writeFile({ fileName: path.join(__dirname, "slide-01-preview.pptx") })
    .then(() => console.log("Created: slide-01-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
