// slide-05.js - Transaction Recording (Content Page)
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

  // Top accent bar
  slide.addShape(pres.ShapeType.rect, {
    x: 0, y: 0, w: 10, h: 0.08,
    fill: { color: t.primary }
  });

  // Title
  slide.addText("Transaction Recording", {
    x: 0.5, y: 0.3, w: 9, h: 0.7,
    fontSize: 32,
    fontFace: "Georgia",
    bold: true,
    color: t.primary,
    align: "left",
    valign: "middle"
  });

  // Divider line under title
  slide.addShape(pres.ShapeType.rect, {
    x: 0.5, y: 1.0, w: 2.5, h: 0.05,
    fill: { color: t.accent }
  });

  // ===== LEFT COLUMN: Bullet points =====
  const bullets = [
    { text: "Type: Income & Expense", options: { bullet: true, breakLine: true } },
    { text: "Categories with custom icons", options: { bullet: true, breakLine: true } },
    { text: "Attachments: photos & arbitrary files", options: { bullet: true, breakLine: true } },
    { text: "Recurring: Daily, Weekly, Monthly", options: { bullet: true, breakLine: true } },
    { text: "Soft delete with restore", options: { bullet: true } }
  ];

  slide.addText(bullets, {
    x: 0.5, y: 1.2, w: 4.5, h: 3.5,
    fontSize: 16,
    fontFace: "Calibri",
    color: t.primary,
    valign: "top",
    paraSpaceAfter: 10
  });

  // ===== RIGHT COLUMN: UI Mockup =====
  // Card container (white card with green header)
  const cardX = 5.5;
  const cardY = 1.2;
  const cardW = 4.0;
  const cardH = 3.8;

  // Card shadow effect (offset rectangle)
  slide.addShape(pres.ShapeType.rect, {
    x: cardX + 0.06, y: cardY + 0.06, w: cardW, h: cardH,
    fill: { color: t.light, transparency: 40 }
  });

  // Card body
  slide.addShape(pres.ShapeType.rect, {
    x: cardX, y: cardY, w: cardW, h: cardH,
    fill: { color: "FFFFFF" },
    line: { color: t.light, width: 1 }
  });

  // Card header bar (green)
  slide.addShape(pres.ShapeType.rect, {
    x: cardX, y: cardY, w: cardW, h: 0.55,
    fill: { color: t.primary }
  });

  // Header title text
  slide.addText("Transactions", {
    x: cardX + 0.2, y: cardY, w: cardW - 0.4, h: 0.55,
    fontSize: 14,
    fontFace: "Calibri",
    bold: true,
    color: "FFFFFF",
    align: "left",
    valign: "middle"
  });

  // Transaction list items (3 rows)
  const rowStartY = cardY + 0.7;
  const rowH = 0.65;
  const items = [
    { icon: "+", label: "Salary", amount: "+ 8,500,000", color: t.accent },
    { icon: "-", label: "Groceries", amount: "- 250,000", color: "E57373" },
    { icon: "-", label: "Transport", amount: "- 45,000", color: "E57373" }
  ];

  items.forEach((item, i) => {
    const rowY = rowStartY + i * rowH;

    // Row background (alternating subtle)
    if (i % 2 === 0) {
      slide.addShape(pres.ShapeType.rect, {
        x: cardX, y: rowY, w: cardW, h: rowH,
        fill: { color: t.bg }
      });
    }

    // Icon circle
    slide.addShape(pres.ShapeType.ellipse, {
      x: cardX + 0.2, y: rowY + 0.15, w: 0.35, h: 0.35,
      fill: { color: item.color }
    });
    slide.addText(item.icon, {
      x: cardX + 0.2, y: rowY + 0.15, w: 0.35, h: 0.35,
      fontSize: 14,
      fontFace: "Calibri",
      bold: true,
      color: "FFFFFF",
      align: "center",
      valign: "middle"
    });

    // Label
    slide.addText(item.label, {
      x: cardX + 0.65, y: rowY, w: 1.8, h: rowH,
      fontSize: 13,
      fontFace: "Calibri",
      color: t.primary,
      align: "left",
      valign: "middle"
    });

    // Amount
    slide.addText(item.amount, {
      x: cardX + 2.3, y: rowY, w: 1.5, h: rowH,
      fontSize: 13,
      fontFace: "Calibri",
      bold: true,
      color: item.icon === "+" ? t.accent : "E57373",
      align: "right",
      valign: "middle"
    });

    // Separator line
    if (i < items.length - 1) {
      slide.addShape(pres.ShapeType.rect, {
        x: cardX + 0.2, y: rowY + rowH - 0.01, w: cardW - 0.4, h: 0.01,
        fill: { color: t.light }
      });
    }
  });

  // Bottom section of card: recurring badge
  const badgeY = rowStartY + 3 * rowH + 0.15;
  slide.addShape(pres.ShapeType.rect, {
    x: cardX + 0.2, y: badgeY, w: 1.3, h: 0.32,
    fill: { color: t.light }
  });
  slide.addText("Recurring", {
    x: cardX + 0.2, y: badgeY, w: 1.3, h: 0.32,
    fontSize: 10,
    fontFace: "Calibri",
    bold: true,
    color: t.secondary,
    align: "center",
    valign: "middle"
  });

  // Attachment icon indicator
  slide.addShape(pres.ShapeType.rect, {
    x: cardX + 1.6, y: badgeY, w: 1.1, h: 0.32,
    fill: { color: t.light }
  });
  slide.addText("+ Attachment", {
    x: cardX + 1.6, y: badgeY, w: 1.1, h: 0.32,
    fontSize: 10,
    fontFace: "Calibri",
    bold: true,
    color: t.secondary,
    align: "center",
    valign: "middle"
  });

  // ===== Page number badge: 5 =====
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("5", {
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
  pres.writeFile({ fileName: "C:/Users/muham/catatan_keuangan/slides-en/slide-05-preview.pptx" })
    .then(() => console.log("slide-05-preview.pptx saved."))
    .catch(err => console.error(err));
}

module.exports = { createSlide };
