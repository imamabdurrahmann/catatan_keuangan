/**
 * Slide 03: Feature Overview - Application Overview
 * Exports createSlide(pres, theme)
 */
function createSlide(pres, theme) {
  const slide = pres.addSlide();

  // --- Background ---
  slide.background = { color: theme.bg };

  // --- Top accent bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 10, h: 0.08,
    fill: { color: theme.accent }
  });

  // --- Left accent bar ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 0.12, h: 5.625,
    fill: { color: theme.primary }
  });

  // --- Page title ---
  slide.addText("Application Overview", {
    x: 0.5, y: 0.2, w: 6.0, h: 0.65,
    fontFace: "Georgia",
    fontSize: 30,
    color: theme.primary,
    bold: true,
    margin: 0
  });

  // --- Title underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.82, w: 3.2, h: 0.04,
    fill: { color: theme.accent }
  });

  // --- Feature cards data ---
  const features = [
    {
      icon: "T",
      label: "Transaction",
      desc: "Daily transaction recording"
    },
    {
      icon: "D",
      label: "Wallet",
      desc: "Multi-wallet with balance"
    },
    {
      icon: "B",
      label: "Budget",
      desc: "Monthly budget per category"
    },
    {
      icon: "P",
      label: "PDF",
      desc: "Monthly reports"
    },
    {
      icon: "BK",
      label: "Backup",
      desc: "AES-256 encrypted backup"
    },
    {
      icon: "K",
      label: "Security",
      desc: "PIN + Biometric"
    }
  ];

  // --- Grid layout: 3 columns x 2 rows ---
  const cardW = 2.8;
  const cardH = 1.65;
  const gapX = 0.35;
  const gapY = 0.3;
  const gridStartX = 0.5;
  const gridStartY = 1.05;

  features.forEach((feat, i) => {
    const col = i % 3;
    const row = Math.floor(i / 3);
    const x = gridStartX + col * (cardW + gapX);
    const y = gridStartY + row * (cardH + gapY);

    // Card background (RECTANGLE with transparency)
    slide.addShape(pres.ShapeType.rect, {
      x: x, y: y, w: cardW, h: cardH,
      fill: { color: "FFFFFF", transparency: 30 },
      line: { color: theme.light, width: 1 },
      rectRadius: 0.08
    });

    // Left color accent strip on card
    slide.addShape(pres.ShapeType.rect, {
      x: x, y: y + 0.08, w: 0.06, h: cardH - 0.16,
      fill: { color: theme.accent }
    });

    // Icon circle
    slide.addShape(pres.ShapeType.ellipse, {
      x: x + 0.2, y: y + 0.2, w: 0.6, h: 0.6,
      fill: { color: theme.primary }
    });

    // Icon letter
    slide.addText(feat.icon, {
      x: x + 0.2, y: y + 0.2, w: 0.6, h: 0.6,
      fontFace: "Georgia",
      fontSize: 18,
      color: "FFFFFF",
      align: "center",
      valign: "middle",
      bold: true,
      margin: 0
    });

    // Feature label
    slide.addText(feat.label, {
      x: x + 0.9, y: y + 0.22, w: 1.7, h: 0.4,
      fontFace: "Calibri",
      fontSize: 17,
      color: theme.primary,
      bold: true,
      valign: "middle",
      margin: 0
    });

    // Feature description
    slide.addText(feat.desc, {
      x: x + 0.2, y: y + 0.9, w: cardW - 0.4, h: 0.55,
      fontFace: "Calibri",
      fontSize: 13,
      color: theme.secondary,
      margin: 0
    });
  });

  // --- Bottom decorative circles ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: -0.4, y: 4.8, w: 1.2, h: 1.2,
    fill: { color: theme.light, transparency: 50 }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.0, y: 4.5, w: 1.3, h: 1.3,
    fill: { color: theme.accent, transparency: 60 }
  });

  // --- Page number badge: 3 ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: theme.primary }
  });
  slide.addText("3", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-03-preview.pptx") })
    .then(() => console.log("Created: slide-03-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
