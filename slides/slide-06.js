// slide-06.js - Multi-Dompet (Content Page)
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
  slide.addText("Multi-Dompet", {
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
    x: 0.5, y: 1.0, w: 2.2, h: 0.05,
    fill: { color: t.accent }
  });

  // ===== LEFT COLUMN: Bullet points =====
  const bullets = [
    { text: "Buat, edit, hapus wallet", options: { bullet: true, breakLine: true } },
    { text: "Warna kustom per wallet", options: { bullet: true, breakLine: true } },
    { text: "Saldo di-sync otomatis", options: { bullet: true, breakLine: true } },
    { text: "Minimal 1 dompet harus ada", options: { bullet: true } }
  ];

  slide.addText(bullets, {
    x: 0.5, y: 1.2, w: 4.5, h: 3.5,
    fontSize: 16,
    fontFace: "Calibri",
    color: t.primary,
    valign: "top",
    paraSpaceAfter: 12
  });

  // ===== RIGHT COLUMN: 3 Wallet Cards =====
  const wallets = [
    { name: "Dompet Utama", balance: "12.450.000", color: "2E7D32", iconColor: t.accent },
    { name: "Tabungan", balance: "5.200.000", color: "1976D2", iconColor: "64B5F6" },
    { name: "Hiburan", balance: "850.000", color: "E65100", iconColor: "FFB74D" }
  ];

  const cardX = 5.2;
  const cardW = 4.3;
  const cardH = 0.9;
  const cardGap = 0.18;
  const startY = 1.2;

  wallets.forEach((wallet, i) => {
    const y = startY + i * (cardH + cardGap);

    // Card shadow
    slide.addShape(pres.ShapeType.rect, {
      x: cardX + 0.05, y: y + 0.05, w: cardW, h: cardH,
      fill: { color: wallet.color, transparency: 75 }
    });

    // Card body (rectangle, not rounded)
    slide.addShape(pres.ShapeType.rect, {
      x: cardX, y: y, w: cardW, h: cardH,
      fill: { color: "FFFFFF" },
      line: { color: wallet.color, width: 1.5 }
    });

    // Color accent bar on left side of card
    slide.addShape(pres.ShapeType.rect, {
      x: cardX, y: y, w: 0.18, h: cardH,
      fill: { color: wallet.color }
    });

    // Wallet icon circle
    slide.addShape(pres.ShapeType.ellipse, {
      x: cardX + 0.35, y: y + 0.22, w: 0.46, h: 0.46,
      fill: { color: wallet.iconColor }
    });

    // Wallet icon symbol (simple "$")
    slide.addText("$", {
      x: cardX + 0.35, y: y + 0.22, w: 0.46, h: 0.46,
      fontSize: 18,
      fontFace: "Georgia",
      bold: true,
      color: "FFFFFF",
      align: "center",
      valign: "middle"
    });

    // Wallet name
    slide.addText(wallet.name, {
      x: cardX + 0.95, y: y + 0.1, w: 2.4, h: 0.38,
      fontSize: 13,
      fontFace: "Calibri",
      bold: true,
      color: t.primary,
      align: "left",
      valign: "middle"
    });

    // Balance label
    slide.addText("Saldo", {
      x: cardX + 0.95, y: y + 0.45, w: 1, h: 0.3,
      fontSize: 10,
      fontFace: "Calibri",
      color: t.secondary,
      align: "left",
      valign: "top"
    });

    // Balance amount
    slide.addText("Rp " + wallet.balance, {
      x: cardX + 1.8, y: y + 0.4, w: 2.2, h: 0.4,
      fontSize: 16,
      fontFace: "Calibri",
      bold: true,
      color: wallet.color,
      align: "right",
      valign: "middle"
    });
  });

  // Bottom note text
  slide.addText("Setiap dompet bisa diatur dengan warna dan ikon kustom untuk pengenalan visual yang mudah.", {
    x: 5.2, y: 4.55, w: 4.3, h: 0.6,
    fontSize: 10,
    fontFace: "Calibri",
    color: t.secondary,
    align: "left",
    valign: "top",
    italic: true
  });

  // ===== Page number badge: 6 =====
  slide.addShape(pres.ShapeType.ellipse, {
    x: 9.3, y: 5.1, w: 0.4, h: 0.4,
    fill: { color: t.primary }
  });
  slide.addText("6", {
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
  pres.writeFile({ fileName: "C:/Users/muham/catatan_keuangan/slides/slide-06-preview.pptx" })
    .then(() => console.log("slide-06-preview.pptx saved."))
    .catch(err => console.error(err));
}

module.exports = { createSlide };
