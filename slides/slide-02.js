/**
 * Slide 02: Table of Contents - Daftar Isi
 * Exports createSlide(pres, theme)
 */
function createSlide(pres, theme) {
  const slide = pres.addSlide();

  // --- Background ---
  slide.background = { color: theme.bg };

  // --- Left accent bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 0.12, h: 5.625,
    fill: { color: theme.primary }
  });

  // --- Top decorative bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 10, h: 0.08,
    fill: { color: theme.accent }
  });

  // --- Page title ---
  slide.addText("Daftar Isi", {
    x: 0.5, y: 0.25, w: 4.0, h: 0.7,
    fontFace: "Georgia",
    fontSize: 34,
    color: theme.primary,
    bold: true,
    margin: 0
  });

  // --- Title underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.92, w: 2.2, h: 0.045,
    fill: { color: theme.accent }
  });

  // --- Table of Contents items ---
  const sections = [
    { num: "01", title: "Gambaran Umum" },
    { num: "02", title: "Pencatatan Transaksi" },
    { num: "03", title: "Multi-Dompet" },
    { num: "04", title: "Budget & Statistik" },
    { num: "05", title: "Laporan PDF" },
    { num: "06", title: "Backup & Enkripsi" },
    { num: "07", title: "Keamanan" },
    { num: "08", title: "Deep Linking & Widget" }
  ];

  const startX = 0.5;
  const startY = 1.2;
  const itemHeight = 0.52;
  const colGap = 4.4;

  sections.forEach((item, i) => {
    const col = i < 4 ? 0 : 1;
    const row = i < 4 ? i : i - 4;
    const x = startX + col * colGap;
    const y = startY + row * itemHeight;

    // Number circle
    slide.addShape(pres.ShapeType.ellipse, {
      x: x, y: y, w: 0.42, h: 0.42,
      fill: { color: theme.primary }
    });

    // Number text
    slide.addText(item.num, {
      x: x, y: y, w: 0.42, h: 0.42,
      fontFace: "Calibri",
      fontSize: 12,
      color: "FFFFFF",
      align: "center",
      valign: "middle",
      bold: true,
      margin: 0
    });

    // Section title
    slide.addText(item.title, {
      x: x + 0.55, y: y, w: 3.6, h: 0.42,
      fontFace: "Calibri",
      fontSize: 16,
      color: theme.secondary,
      valign: "middle",
      margin: 0
    });

    // Connector dot
    slide.addShape(pres.ShapeType.ellipse, {
      x: x + 0.55, y: y + 0.46, w: 0.06, h: 0.06,
      fill: { color: theme.light }
    });
  });

  // --- Decorative element: vertical divider between columns ---
  slide.addShape(pres.ShapeType.rect, {
    x: 4.65, y: 1.2, w: 0.025, h: 2.0,
    fill: { color: theme.light }
  });

  // --- Bottom decorative shapes ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 8.8, y: 4.6, w: 1.5, h: 1.5,
    fill: { color: theme.light, transparency: 55 }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.1, y: 4.2, w: 0.6, h: 0.6,
    fill: { color: theme.accent, transparency: 50 }
  });

  // --- Page number badge: 2 (circle at x:9.3, y:5.1) ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: theme.primary }
  });
  slide.addText("2", {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fontFace: "Calibri",
    fontSize: 13,
    color: "FFFFFF",
    align: "center",
    valign: "middle",
    bold: true,
    margin: 0
  });
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-02-preview.pptx") })
    .then(() => console.log("Created: slide-02-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
