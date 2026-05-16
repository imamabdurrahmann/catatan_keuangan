/**
 * Slide 09: Section Divider - Operasi & Keamanan
 * Bold center with green accent bar (matching slide-04 style)
 */
function createSlide(pres, customTheme) {
  const t = customTheme || {
    primary: "2E7D32",
    secondary: "388E3C",
    accent: "66BB6A",
    light: "A5D6A7",
    bg: "F1F8E9"
  };

  const slide = pres.addSlide();
  slide.background = { color: t.bg };

  // --- Large horizontal bar spanning the slide ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 2.2, w: 10, h: 1.2,
    fill: { color: t.primary }
  });

  // --- Thin accent line above the bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 2.1, w: 10, h: 0.06,
    fill: { color: t.accent }
  });

  // --- Thin accent line below the bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 3.44, w: 10, h: 0.06,
    fill: { color: t.light }
  });

  // --- Section number "02" ---
  slide.addText("02", {
    x: 0.6, y: 1.4, w: 2, h: 1.2,
    fontSize: 72,
    fontFace: "Georgia",
    bold: true,
    color: t.light,
    align: "left",
    valign: "bottom"
  });

  // --- Section title "Operasi & Keamanan" ---
  slide.addText("Operasi & Keamanan", {
    x: 0.5, y: 2.2, w: 9, h: 1.2,
    fontSize: 44,
    fontFace: "Georgia",
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  // --- Subtitle ---
  slide.addText("Backup, enkripsi, dan keamanan aplikasi", {
    x: 0.5, y: 3.6, w: 9, h: 0.6,
    fontSize: 20,
    fontFace: "Calibri",
    color: t.secondary,
    align: "center",
    valign: "top"
  });

  // --- Decorative geometric elements - bottom left ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 4.8, w: 0.4, h: 0.08,
    fill: { color: t.accent }
  });
  slide.addShape(pres.ShapeType.rect, {
    x: 1.0, y: 4.8, w: 0.2, h: 0.08,
    fill: { color: t.light }
  });

  // --- Page number badge ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("9", {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fontSize: 12,
    fontFace: "Calibri",
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  return slide;
}

// --- Standalone preview ---
if (typeof require !== "undefined") {
  const PptxGenJS = require("C:/Users/muham/catatan_keuangan/node_modules/pptxgenjs");
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-09-preview.pptx") })
    .then(() => console.log("Created: slide-09-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
