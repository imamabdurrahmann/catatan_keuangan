/**
 * Slide 10: Backup & Encryption (Content Page)
 * Two-column comparison layout with encryption flow diagram
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
  slide.addText("Backup & Encryption", {
    x: 0.5, y: 0.3, w: 9, h: 0.7,
    fontFace: "Georgia",
    fontSize: 32,
    bold: true,
    color: t.primary
  });

  // --- Title underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.95, w: 2.6, h: 0.05,
    fill: { color: t.accent }
  });

  // ============ LEFT COLUMN: Backup ============
  const colLeftX = 0.5;
  const colW = 4.2;

  // Left column header card
  slide.addShape(pres.ShapeType.rect, {
    x: colLeftX, y: 1.2, w: colW, h: 0.5,
    fill: { color: t.primary }
  });
  slide.addText("Backup", {
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
    x: colLeftX, y: 1.7, w: colW, h: 2.4,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  const leftItems = [
    "Backup file list with metadata",
    "AES-256-CBC Encryption",
    "Swipe-to-delete",
    "Share via system",
    "Restore from list or file picker"
  ];

  leftItems.forEach((item, i) => {
    // Bullet dot
    slide.addShape(pres.ShapeType.ellipse, {
      x: colLeftX + 0.2, y: 1.85 + i * 0.42,
      w: 0.12, h: 0.12,
      fill: { color: t.accent }
    });
    // Text
    slide.addText(item, {
      x: colLeftX + 0.4, y: 1.78 + i * 0.42, w: colW - 0.5, h: 0.4,
      fontFace: "Calibri",
      fontSize: 13,
      color: t.secondary,
      valign: "middle",
      margin: 0
    });
  });

  // ============ RIGHT COLUMN: Security ============
  const colRightX = 5.2;

  // Right column header card
  slide.addShape(pres.ShapeType.rect, {
    x: colRightX, y: 1.2, w: colW, h: 0.5,
    fill: { color: t.secondary }
  });
  slide.addText("Security", {
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
    x: colRightX, y: 1.7, w: colW, h: 2.4,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  const rightItems = [
    "PIN Lock 4-6 digit",
    "Biometric (Fingerprint/Face)",
    "Auto-lock on background",
    "PIN required if biometric enabled"
  ];

  rightItems.forEach((item, i) => {
    // Bullet dot
    slide.addShape(pres.ShapeType.ellipse, {
      x: colRightX + 0.2, y: 1.85 + i * 0.42,
      w: 0.12, h: 0.12,
      fill: { color: t.accent }
    });
    // Text
    slide.addText(item, {
      x: colRightX + 0.4, y: 1.78 + i * 0.42, w: colW - 0.5, h: 0.4,
      fontFace: "Calibri",
      fontSize: 13,
      color: t.secondary,
      valign: "middle",
      margin: 0
    });
  });

  // ============ ENCRYPTION FLOW DIAGRAM ============
  const flowY = 4.3;
  const boxW = 1.8;
  const boxH = 0.55;
  const arrowW = 0.6;

  // Box 1: Data
  slide.addShape(pres.ShapeType.rect, {
    x: 1.8, y: flowY, w: boxW, h: boxH,
    fill: { color: t.light },
    line: { color: t.accent, width: 1.5 }
  });
  slide.addText("Data", {
    x: 1.8, y: flowY, w: boxW, h: boxH,
    fontFace: "Calibri",
    fontSize: 13,
    bold: true,
    color: t.primary,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Arrow 1
  slide.addShape(pres.ShapeType.rect, {
    x: 1.8 + boxW + 0.15, y: flowY + boxH / 2 - 0.04, w: arrowW, h: 0.08,
    fill: { color: t.accent }
  });
  // Arrowhead 1
  slide.addText("\u25B6", {
    x: 1.8 + boxW + arrowW - 0.05, y: flowY + boxH / 2 - 0.2, w: 0.3, h: 0.4,
    fontSize: 12,
    color: t.accent,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Box 2: AES-256-CBC
  slide.addShape(pres.ShapeType.rect, {
    x: 1.8 + boxW + arrowW + 0.3, y: flowY, w: boxW + 0.4, h: boxH,
    fill: { color: t.primary }
  });
  slide.addText("AES-256-CBC", {
    x: 1.8 + boxW + arrowW + 0.3, y: flowY, w: boxW + 0.4, h: boxH,
    fontFace: "Calibri",
    fontSize: 13,
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Arrow 2
  slide.addShape(pres.ShapeType.rect, {
    x: 1.8 + boxW * 2 + arrowW + 0.45 + 0.15, y: flowY + boxH / 2 - 0.04, w: arrowW, h: 0.08,
    fill: { color: t.accent }
  });
  // Arrowhead 2
  slide.addText("\u25B6", {
    x: 1.8 + boxW * 2 + arrowW * 2 + 0.45 + 0.05, y: flowY + boxH / 2 - 0.2, w: 0.3, h: 0.4,
    fontSize: 12,
    color: t.accent,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Box 3: Encrypted File
  slide.addShape(pres.ShapeType.rect, {
    x: 1.8 + (boxW + 0.4) * 2 + arrowW * 2 + 0.6, y: flowY, w: boxW, h: boxH,
    fill: { color: t.light },
    line: { color: t.accent, width: 1.5 }
  });
  slide.addText("Encrypted File", {
    x: 1.8 + (boxW + 0.4) * 2 + arrowW * 2 + 0.6, y: flowY, w: boxW, h: boxH,
    fontFace: "Calibri",
    fontSize: 13,
    bold: true,
    color: t.primary,
    align: "center",
    valign: "middle",
    margin: 0
  });

  // Flow label
  slide.addText("Encryption Flow", {
    x: 0.5, y: flowY - 0.05, w: 1.2, h: 0.35,
    fontFace: "Calibri",
    fontSize: 10,
    color: t.accent,
    align: "left",
    valign: "bottom",
    margin: 0
  });

  // ============ PAGE NUMBER BADGE ============
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("10", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-10-preview.pptx") })
    .then(() => console.log("Created: slide-10-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
