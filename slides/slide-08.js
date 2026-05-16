/**
 * Slide 08: Laporan PDF (Content Page)
 * Mixed media layout: bullets left, PDF mockup right
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
  slide.addText("Laporan PDF", {
    x: 0.5, y: 0.25, w: 9, h: 0.65,
    fontSize: 32,
    fontFace: "Georgia",
    bold: true,
    color: t.primary
  });

  // --- Decorative underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.88, w: 2.0, h: 0.05,
    fill: { color: t.accent }
  });

  // ===== LEFT: Bullet points =====
  const leftX = 0.5;
  const leftW = 4.5;

  // Bullet card background
  slide.addShape(pres.ShapeType.rect, {
    x: leftX, y: 1.15, w: leftW, h: 3.8,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  // Accent left border
  slide.addShape(pres.ShapeType.rect, {
    x: leftX, y: 1.15, w: 0.08, h: 3.8,
    fill: { color: t.primary }
  });

  // Bullet points
  slide.addText([
    { text: "Generate laporan bulanan", options: { bullet: true, breakLine: true } },
    { text: "Thumbnail lampiran di PDF", options: { bullet: true, breakLine: true } },
    { text: "Share via printing package", options: { bullet: true, breakLine: true } },
    { text: "Max 4 gambar per transaksi", options: { bullet: true } }
  ], {
    x: leftX + 0.25, y: 1.35, w: leftW - 0.4, h: 3.4,
    fontSize: 15,
    fontFace: "Calibri",
    color: t.secondary,
    valign: "top",
    paraSpaceAfter: 14
  });

  // ===== RIGHT: PDF document mockup =====
  const docX = 5.4;
  const docY = 1.0;
  const docW = 4.0;
  const docH = 4.1;

  // Shadow offset rectangles (decorative depth)
  slide.addShape(pres.ShapeType.rect, {
    x: docX + 0.08, y: docY + 0.08, w: docW, h: docH,
    fill: { color: t.light, transparency: 30 },
    line: { color: t.light, width: 0 }
  });

  // Main document white background
  slide.addShape(pres.ShapeType.rect, {
    x: docX, y: docY, w: docW, h: docH,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1.5 }
  });

  // PDF header (green top bar)
  slide.addShape(pres.ShapeType.rect, {
    x: docX, y: docY, w: docW, h: 0.55,
    fill: { color: t.primary }
  });

  // PDF title text in header
  slide.addText("Catatan Keuangan", {
    x: docX + 0.15, y: docY, w: docW - 0.3, h: 0.55,
    fontSize: 14,
    fontFace: "Georgia",
    bold: true,
    color: "FFFFFF",
    valign: "middle"
  });

  // PDF filename label
  slide.addShape(pres.ShapeType.rect, {
    x: docX + 0.15, y: docY + 0.65, w: 2.2, h: 0.28,
    fill: { color: t.light, transparency: 30 }
  });
  slide.addText("Catatan_Keuangan_April_2026.pdf", {
    x: docX + 0.15, y: docY + 0.65, w: docW - 0.3, h: 0.28,
    fontSize: 8,
    fontFace: "Calibri",
    color: t.secondary,
    valign: "middle"
  });

  // --- Table header row ---
  const tableY = docY + 1.05;
  const tableX = docX + 0.15;
  const col1W = 1.2;
  const col2W = 1.1;
  const col3W = 1.1;
  const rowH = 0.32;

  slide.addShape(pres.ShapeType.rect, {
    x: tableX, y: tableY, w: col1W + col2W + col3W, h: rowH,
    fill: { color: t.accent, transparency: 40 }
  });

  // Table header text
  slide.addText("Kategori", {
    x: tableX, y: tableY, w: col1W, h: rowH,
    fontSize: 8, fontFace: "Calibri", bold: true,
    color: t.primary, align: "center", valign: "middle"
  });
  slide.addText("Budget", {
    x: tableX + col1W, y: tableY, w: col2W, h: rowH,
    fontSize: 8, fontFace: "Calibri", bold: true,
    color: t.primary, align: "center", valign: "middle"
  });
  slide.addText("Aktual", {
    x: tableX + col1W + col2W, y: tableY, w: col3W, h: rowH,
    fontSize: 8, fontFace: "Calibri", bold: true,
    color: t.primary, align: "center", valign: "middle"
  });

  // --- Table data rows ---
  const rows = [
    ["Makanan", "Rp 2.000.000", "Rp 1.600.000"],
    ["Transport", "Rp 500.000", "Rp 225.000"],
    ["Hiburan", "Rp 300.000", "Rp 300.000"]
  ];

  rows.forEach((row, i) => {
    const rY = tableY + rowH + (i * rowH);
    // Alternating row background
    if (i % 2 === 0) {
      slide.addShape(pres.ShapeType.rect, {
        x: tableX, y: rY, w: col1W + col2W + col3W, h: rowH,
        fill: { color: t.bg }
      });
    }
    row.forEach((cell, j) => {
      const cellX = j === 0 ? tableX : tableX + col1W + (j - 1) * (col2W);
      const cellW = j === 0 ? col1W : (j === 1 ? col2W : col3W);
      slide.addText(cell, {
        x: cellX, y: rY, w: cellW, h: rowH,
        fontSize: 7.5, fontFace: "Calibri",
        color: t.secondary,
        align: "center", valign: "middle"
      });
    });
  });

  // --- Image thumbnails section (4 small rectangles) ---
  const thumbY = tableY + rowH + (rows.length * rowH) + 0.12;
  const thumbSize = 0.55;
  const thumbGap = 0.08;
  const thumbStartX = tableX;

  // Label above thumbnails
  slide.addText("Lampiran Gambar", {
    x: thumbStartX, y: thumbY - 0.2, w: 2, h: 0.2,
    fontSize: 7, fontFace: "Calibri",
    color: t.secondary, bold: true
  });

  for (let i = 0; i < 4; i++) {
    const tx = thumbStartX + i * (thumbSize + thumbGap);
    slide.addShape(pres.ShapeType.rect, {
      x: tx, y: thumbY, w: thumbSize, h: thumbSize,
      fill: { color: t.bg },
      line: { color: t.light, width: 0.8 }
    });
    // Small placeholder "img" text
    slide.addText("img", {
      x: tx, y: thumbY, w: thumbSize, h: thumbSize,
      fontSize: 7, fontFace: "Calibri",
      color: t.light, align: "center", valign: "middle"
    });
  }

  // ===== Filename callout below the mockup =====
  slide.addShape(pres.ShapeType.rect, {
    x: docX, y: docY + docH + 0.08, w: docW, h: 0.38,
    fill: { color: t.primary, transparency: 15 },
    line: { color: t.primary, width: 1 }
  });
  slide.addText("Catatan_Keuangan_April_2026.pdf", {
    x: docX, y: docY + docH + 0.08, w: docW, h: 0.38,
    fontSize: 10,
    fontFace: "Calibri",
    color: t.primary,
    align: "center",
    valign: "middle"
  });

  // --- Page number badge ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("8", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-08-preview.pptx") })
    .then(() => console.log("Created: slide-08-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
