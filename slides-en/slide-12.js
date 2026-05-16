/**
 * Slide 12: Summary / Closing Page
 * 2x2 grid of key takeaways with tagline
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

  // --- Decorative circles (subtle) ---
  slide.addShape(pres.ShapeType.ellipse, {
    x: -0.5, y: -0.5, w: 2.0, h: 2.0,
    fill: { color: t.light, transparency: 60 }
  });
  slide.addShape(pres.ShapeType.ellipse, {
    x: 8.8, y: 4.2, w: 1.8, h: 1.8,
    fill: { color: t.light, transparency: 60 }
  });

  // --- Title ---
  slide.addText("Summary", {
    x: 0.5, y: 0.25, w: 9, h: 0.65,
    fontFace: "Georgia",
    fontSize: 32,
    bold: true,
    color: t.primary
  });

  // --- Title underline ---
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 0.85, w: 1.4, h: 0.05,
    fill: { color: t.accent }
  });

  // ============ 2x2 GRID OF CARDS ============
  const cardW = 4.2;
  const cardH = 1.5;
  const gapX = 0.5;
  const gapY = 0.3;
  const startX = 0.55;
  const startY = 1.1;

  const cards = [
    {
      stat: "63 Test Cases",
      desc: "Unit & widget tests",
      color: t.primary
    },
    {
      stat: "AES-256-CBC",
      desc: "End-to-end encryption",
      color: t.secondary
    },
    {
      stat: "3 APK Variants",
      desc: "armeabi, arm64, universal",
      color: t.accent
    },
    {
      stat: "Material 3",
      desc: "Light & Dark theme",
      color: t.light
    }
  ];

  // Alternate text color based on card fill
  const cardTextColor = (fillColor) => {
    if (fillColor === t.light) return t.primary;
    return "FFFFFF";
  };

  cards.forEach((card, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = startX + col * (cardW + gapX);
    const y = startY + row * (cardH + gapY);

    // Card background
    slide.addShape(pres.ShapeType.rect, {
      x: x, y: y, w: cardW, h: cardH,
      fill: { color: card.color },
      rectRadius: 0.08
    });

    // Left accent stripe
    slide.addShape(pres.ShapeType.rect, {
      x: x, y: y, w: 0.1, h: cardH,
      fill: { color: t.primary, transparency: 30 },
      rectRadius: 0.08
    });

    // Stat text (large)
    slide.addText(card.stat, {
      x: x + 0.25, y: y + 0.2, w: cardW - 0.4, h: 0.7,
      fontFace: "Georgia",
      fontSize: 26,
      bold: true,
      color: cardTextColor(card.color),
      align: "left",
      valign: "middle",
      margin: 0
    });

    // Desc text (smaller)
    slide.addText(card.desc, {
      x: x + 0.25, y: y + 0.9, w: cardW - 0.4, h: 0.45,
      fontFace: "Calibri",
      fontSize: 14,
      color: cardTextColor(card.color),
      align: "left",
      valign: "top",
      margin: 0
    });
  });

  // ============ BOTTOM TAGLINE ============
  // Tagline background strip
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 4.75, w: 10, h: 0.65,
    fill: { color: t.primary }
  });

  slide.addText("Personal Finance Tracker \u2014 Manage your finances wisely", {
    x: 0.5, y: 4.75, w: 8.3, h: 0.65,
    fontFace: "Calibri",
    fontSize: 16,
    italic: true,
    color: "FFFFFF",
    align: "center",
    valign: "middle"
  });

  // ============ PAGE NUMBER BADGE ============
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.accent }
  });
  slide.addText("12", {
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

  pres.writeFile({ fileName: path.join(__dirname, "slide-12-preview.pptx") })
    .then(() => console.log("Created: slide-12-preview.pptx"))
    .catch(err => console.error("Error:", err));
}

module.exports = { createSlide };
