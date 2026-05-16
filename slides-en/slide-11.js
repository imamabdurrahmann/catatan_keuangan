/**
 * Slide 11: Deep Linking & Home Widget (Content Page)
 * Two-column layout
 * Theme: Forest & Eco Green
 * Slide dimensions: 10" x 5.625" (LAYOUT_16x9)
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

  // --- Title ---
  slide.addText("Deep Linking & Home Widget", {
    x: 0.5, y: 0.3, w: 9, h: 0.7,
    fontFace: "Georgia",
    fontSize: 32,
    bold: true,
    color: t.primary
  });

  // --- Title underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.95, w: 3.0, h: 0.05,
    fill: { color: t.accent }
  });

  // ============ LEFT COLUMN: Deep Linking ============
  const colLeftX = 0.5;
  const colW = 4.2;

  // Left column header card
  slide.addShape(pres.ShapeType.rect, {
    x: colLeftX, y: 1.2, w: colW, h: 0.5,
    fill: { color: t.primary }
  });
  slide.addText("Deep Linking", {
    x: colLeftX, y: 1.2, w: colW, h: 0.5,
    fontFace: "Georgia",
    fontSize: 18,
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Left column body
  slide.addShape(pres.ShapeType.rect, {
    x: colLeftX, y: 1.7, w: colW, h: 2.6,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  const leftItems = [
    { label: "Custom scheme", value: "catalog://" },
    { label: "Routes", value: "/, /settings, /statistik" },
    { label: "Integration", value: "GoRouter 14.x" },
    { label: "Platform", value: "Android & iOS configured" }
  ];

  leftItems.forEach((item, i) => {
    // Bullet dot
    slide.addShape(pres.ShapeType.ellipse, {
      x: colLeftX + 0.2, y: 1.92 + i * 0.55,
      w: 0.12, h: 0.12,
      fill: { color: t.accent }
    });
    // Label
    slide.addText(item.label + ":", {
      x: colLeftX + 0.4, y: 1.82 + i * 0.55, w: colW - 0.5, h: 0.3,
      fontFace: "Calibri",
      fontSize: 13,
      bold: true,
      color: t.primary,
      valign: "middle",
      margin: 0
    });
    // Value
    slide.addText(item.value, {
      x: colLeftX + 0.4, y: 2.08 + i * 0.55, w: colW - 0.5, h: 0.3,
      fontFace: "Calibri",
      fontSize: 12,
      color: t.secondary,
      valign: "middle",
      margin: 0
    });
  });

  // ============ RIGHT COLUMN: Android Widget ============
  const colRightX = 5.2;

  // Right column header card
  slide.addShape(pres.ShapeType.rect, {
    x: colRightX, y: 1.2, w: colW, h: 0.5,
    fill: { color: t.secondary }
  });
  slide.addText("Android Widget", {
    x: colRightX, y: 1.2, w: colW, h: 0.5,
    fontFace: "Georgia",
    fontSize: 18,
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Right column body
  slide.addShape(pres.ShapeType.rect, {
    x: colRightX, y: 1.7, w: colW, h: 2.6,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  const rightItems = [
    { label: "Display", value: "Show balance on home screen" },
    { label: "Update", value: "Auto update on transaction" },
    { label: "Format", value: "1.2jt, 500rb" },
    { label: "Layout", value: "Native Android XML" }
  ];

  rightItems.forEach((item, i) => {
    // Bullet dot
    slide.addShape(pres.ShapeType.ellipse, {
      x: colRightX + 0.2, y: 1.92 + i * 0.55,
      w: 0.12, h: 0.12,
      fill: { color: t.accent }
    });
    // Label
    slide.addText(item.label + ":", {
      x: colRightX + 0.4, y: 1.82 + i * 0.55, w: colW - 0.5, h: 0.3,
      fontFace: "Calibri",
      fontSize: 13,
      bold: true,
      color: t.primary,
      valign: "middle",
      margin: 0
    });
    // Value
    slide.addText(item.value, {
      x: colRightX + 0.4, y: 2.08 + i * 0.55, w: colW - 0.5, h: 0.3,
      fontFace: "Calibri",
      fontSize: 12,
      color: t.secondary,
      valign: "middle",
      margin: 0
    });
  });

  // ============ DECORATIVE SCHEME BADGE ============
  slide.addShape(pres.ShapeType.rect, {
    x: 1.5, y: 4.5, w: 1.6, h: 0.45,
    fill: { color: t.light, transparency: 30 },
    line: { color: t.accent, width: 1 }
  });
  slide.addText("catalog://", {
    x: 1.5, y: 4.5, w: 1.6, h: 0.45,
    fontFace: "Calibri",
    fontSize: 11,
    bold: true,
    color: t.primary,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Arrow from scheme to routes
  slide.addShape(pres.ShapeType.rect, {
    x: 3.15, y: 4.72, w: 0.4, h: 0.06,
    fill: { color: t.accent }
  });
  slide.addText("\u25B6", {
    x: 3.5, y: 4.55, w: 0.25, h: 0.4,
    fontSize: 10,
    color: t.accent,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Route badges
  const routes = ["/", "/settings", "/statistik"];
  const routeStartX = 3.8;
  routes.forEach((route, i) => {
    slide.addShape(pres.ShapeType.rect, {
      x: routeStartX + i * 1.15, y: 4.5, w: 1.05, h: 0.45,
      fill: { color: t.accent, transparency: 20 },
      line: { color: t.accent, width: 1 }
    });
    slide.addText(route, {
      x: routeStartX + i * 1.15, y: 4.5, w: 1.05, h: 0.45,
      fontFace: "Calibri",
      fontSize: 10,
      bold: true,
      color: t.primary,
      align: "center",
      valign: "middle",
      margin: 0
    });
  });

  // ============ PAGE NUMBER BADGE ============
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("11", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-11-preview.pptx") })
    .then(() => console.log("Created: slide-11-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
