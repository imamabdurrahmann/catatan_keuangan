/**
 * Slide 07: Budget & Statistics (Content Page)
 * Two-column layout with budget progress and statistics
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

  // --- Top accent bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 10, h: 0.08,
    fill: { color: t.primary }
  });

  // --- Slide title ---
  slide.addText("Budget & Statistics", {
    x: 0.5, y: 0.25, w: 9, h: 0.65,
    fontSize: 32,
    fontFace: "Georgia",
    bold: true,
    color: t.primary
  });

  // --- Decorative underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.88, w: 2.2, h: 0.05,
    fill: { color: t.accent }
  });

  // ===== LEFT SECTION: Monthly Budget =====
  const leftX = 0.5;
  const leftW = 4.3;
  const sectionY = 1.15;

  // Left section header background
  slide.addShape(pres.ShapeType.rect, {
    x: leftX, y: sectionY, w: leftW, h: 0.5,
    fill: { color: t.primary }
  });
  slide.addText("Monthly Budget", {
    x: leftX, y: sectionY, w: leftW, h: 0.5,
    fontSize: 18,
    fontFace: "Georgia",
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  // Left section content box
  slide.addShape(pres.ShapeType.rect, {
    x: leftX, y: sectionY + 0.5, w: leftW, h: 2.0,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  // Left bullet points
  slide.addText([
    { text: "Set budget per category per month", options: { bullet: true, breakLine: true } },
    { text: "Progress bar green \u2192 red", options: { bullet: true, breakLine: true } },
    { text: "Comparison with actual", options: { bullet: true } }
  ], {
    x: leftX + 0.15, y: sectionY + 0.6, w: leftW - 0.3, h: 1.8,
    fontSize: 13,
    fontFace: "Calibri",
    color: t.secondary,
    valign: "top",
    paraSpaceAfter: 8
  });

  // ===== RIGHT SECTION: Statistics =====
  const rightX = 5.2;
  const rightW = 4.3;

  // Right section header background
  slide.addShape(pres.ShapeType.rect, {
    x: rightX, y: sectionY, w: rightW, h: 0.5,
    fill: { color: t.secondary }
  });
  slide.addText("Statistics", {
    x: rightX, y: sectionY, w: rightW, h: 0.5,
    fontSize: 18,
    fontFace: "Georgia",
    bold: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  // Right section content box
  slide.addShape(pres.ShapeType.rect, {
    x: rightX, y: sectionY + 0.5, w: rightW, h: 2.0,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  // Right bullet points
  slide.addText([
    { text: "Summary per category", options: { bullet: true, breakLine: true } },
    { text: "Progress indicator visual", options: { bullet: true, breakLine: true } },
    { text: "Month/year navigation", options: { bullet: true } }
  ], {
    x: rightX + 0.15, y: sectionY + 0.6, w: rightW - 0.3, h: 1.8,
    fontSize: 13,
    fontFace: "Calibri",
    color: t.secondary,
    valign: "top",
    paraSpaceAfter: 8
  });

  // ===== BOTTOM: Progress bars section =====
  const barY = 3.85;
  const barH = 0.38;
  const barW = 6.5;
  const barX = 0.5;
  const labelW = 2.2;

  // Section label
  slide.addText("Expense Progress", {
    x: barX, y: barY - 0.35, w: 4, h: 0.35,
    fontSize: 12,
    fontFace: "Calibri",
    color: t.secondary,
    bold: true
  });

  // Helper to draw a progress bar row
  function addProgressBar(label, pct, barColor, y) {
    // Track bar background (full width)
    slide.addShape(pres.ShapeType.rect, {
      x: barX, y: y, w: barW, h: barH,
      fill: { color: t.light, transparency: 40 },
      line: { color: t.light, width: 0.5 }
    });
    // Filled portion
    const fillW = barW * (pct / 100);
    slide.addShape(pres.ShapeType.rect, {
      x: barX, y: y, w: fillW, h: barH,
      fill: { color: barColor }
    });
    // Label text on the left
    slide.addText(label, {
      x: barX + 0.1, y: y, w: labelW, h: barH,
      fontSize: 12,
      fontFace: "Calibri",
      color: pct >= 90 ? "FFFFFF" : t.primary,
      bold: true,
      valign: "middle"
    });
    // Percentage text on the right edge
    slide.addText(pct + "%", {
      x: barX + barW - 0.55, y: y, w: 0.5, h: barH,
      fontSize: 11,
      fontFace: "Calibri",
      color: pct >= 90 ? "FFFFFF" : t.secondary,
      bold: true,
      align: "right",
      valign: "middle"
    });
  }

  // Food 80% (green)
  addProgressBar("Food", 80, t.primary, barY);
  // Transport 45% (green)
  addProgressBar("Transport", 45, t.secondary, barY + 0.5);
  // Entertainment 100% (red - over budget)
  addProgressBar("Entertainment", 100, "E53935", barY + 1.0);

  // --- Decorative element bottom right ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 8.6, y: 4.0, w: 1.6, h: 1.6,
    fill: { color: t.light, transparency: 60 }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.0, y: 4.4, w: 0.8, h: 0.8,
    fill: { color: t.accent, transparency: 50 }
  });

  // --- Page number badge ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("7", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-07-preview.pptx") })
    .then(() => console.log("Created: slide-07-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
