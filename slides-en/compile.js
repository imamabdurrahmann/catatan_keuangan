const pptxgen = require('pptxgenjs');
const pres = new pptxgen();
pres.layout = 'LAYOUT_16x9';
pres.title = 'Personal Finance Tracker';
pres.author = 'Flutter App Documentation';
pres.subject = 'Personal Finance App Presentation';

const theme = {
  primary: "2E7D32",
  secondary: "388E3C",
  accent: "66BB6A",
  light: "A5D6A7",
  bg: "F1F8E9"
};

for (let i = 1; i <= 12; i++) {
  const num = String(i).padStart(2, '0');
  const slideModule = require(`./slide-${num}.js`);
  slideModule.createSlide(pres, theme);
}

pres.writeFile({ fileName: './output/Personal_Finance_Tracker_EN.pptx' })
  .then(() => {
    const fs = require('fs');
    const size = fs.statSync('./output/Personal_Finance_Tracker_EN.pptx').size;
    console.log(`PPTX DISIMPAN: ./output/Personal_Finance_Tracker_EN.pptx (${(size/1024).toFixed(1)} KB)`);
  })
  .catch(err => {
    console.error('ERROR:', err);
    process.exit(1);
  });
