// slide-04.js - Section Divider: Fitur Utama
// Theme: Forest & Eco Green
// Slide dimensions: 10" x 5.625" (LAYOUT_16x9)

const pptxgen = require("pptxgenjs");

const theme = {
  primary: "2E7D32",
  secondary: "388E3C",
  accent: "66BB6A",
  light: "A5D6A7",
  bg: "F1F8E9"
};

function createSlide(pres, customTheme) {
  const t = customTheme || theme;
  const slide = pres.addSlide();

  // Background: very light green
  slide.background = { color: t.bg };

  // Decorative geometric block - horizontal bar (accent shape)
  // Large horizontal bar spanning the slide
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 2.2, w: 10, h: 1.2,
    fill: { color: t.primary }
  });

  // Thin accent line above the bar
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 2.1, w: 10, h: 0.06,
    fill: { color: t.accent }
  });

  // Thin accent line below the bar
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 3.44, w: 10, h: 0.06,
    fill: { color: t.light }
  });

  // Section number "01" - large, light, on the left side of the bar
  slide.addText("01", {
    x: 0.6, y: 1.4, w: 2, h: 1.2,
    fontSize: 72,
    fontFace: "Georgia",
    bold: true,
    color: t.light,
    align: "left",
    valign: "bottom"
  });

  // Section title "Fitur Utama" - bold white on the green bar
  slide.addText("Fitur Utama", {
    x: 0.5, y: 2.2, w: 9, h: 1.2,
    fontSize: 44,
    fontFace: "Georgia",
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  // Subtitle below the bar
  slide.addText("Kemampuan inti aplikasi", {
    x: 0.5, y: 3.6, w: 9, h: 0.6,
    fontSize: 20,
    fontFace: "Calibri",
    color: t.secondary,
    align: "center",
    valign: "top"
  });

  // Small decorative geometric element - bottom left
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 4.8, w: 0.4, h: 0.08,
    fill: { color: t.accent }
  });
  slide.addShape(pres.ShapeType.rect, {
    x: 1.0, y: 4.8, w: 0.2, h: 0.08,
    fill: { color: t.light }
  });

  // Page number badge: circle at x:9.3, y:5.1
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("4", {
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

// Standalone preview
if (require.main === module) {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_16x9";
  pres.defineLayout({ name: "CUSTOM_16x9", width: 10, height: 5.625 });
  pres.layout = "CUSTOM_16x9";
  createSlide(pres, theme);
  pres.writeFile({ fileName: "C:/Users/muham/catatan_keuangan/slides/slide-04-preview.pptx" })
    .then(() => console.log("slide-04-preview.pptx saved."))
    .catch(err => console.error(err));
}

module.exports = { createSlide };
