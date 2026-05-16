const pptxgen = require('pptxgenjs');
const pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';
pres.title = 'Catatan Keuangan';
pres.author = 'Flutter App Documentation';
pres.subject = 'Personal Finance App Presentation';

// Forest & Eco Green theme matching app primary color #2E7D32
const theme = {
  primary: "2E7D32",    // dark green (primary accent)
  secondary: "388E3C",  // medium dark green
  accent: "66BB6A",     // light green
  light: "A5D6A7",      // lighter green
  bg: "F1F8E9"          // very light green background
};

// Load and create all 12 slides
for (let i = 1; i <= 12; i++) {
  const num = String(i).padStart(2, '0');
  const slideModule = require(`./slide-${num}.js`);
  slideModule.createSlide(pres, theme);
}

// Write output
pres.writeFile({ fileName: './output/Catatan_Keuangan_Presentation.pptx' })
  .then(() => {
    const fs = require('fs');
    const size = fs.statSync('./output/Catatan_Keuangan_Presentation.pptx').size;
    console.log(`PPTX DISIMPAN: ./output/Catatan_Keuangan_Presentation.pptx (${(size/1024).toFixed(1)} KB)`);
  })
  .catch(err => {
    console.error('ERROR:', err);
    process.exit(1);
  });
