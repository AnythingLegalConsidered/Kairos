const fs = require('fs');

function fixEncoding(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Fix double-encoded UTF-8 characters
  const fixes = {
    'â–²': '▲',
    'â–¼': '▼',
    'â—€': '◀',
    'â–¶': '▶',
    'â˜…': '★',
    'â˜†': '☆',
    'âœ"': '✓',
    'â—‹': '○',
    'â†—': '↗',
    'âœŽ': '✎',
    'âŒ': '❌',
    'Ã©': 'é',
    'Ã¨': 'è',
    'Ã ': 'à',
    'Ã§': 'ç',
    'Ã´': 'ô',
    'Ã®': 'î',
    'Ã¢': 'â',
    'Ãª': 'ê',
    'Ã«': 'ë',
    'Ã¯': 'ï',
    'Ã¹': 'ù',
    'Ã»': 'û',
    'Ã¼': 'ü',
    'Ã‰': 'É',
    'Ã€': 'À',
    'Ã‚': 'Â',
    'Ãˆ': 'È',
    'Ãœ': 'Ü',
    'â€"': '–',
    'â€™': "'",
    'â€œ': '"',
    'â€': '"',
    'â€¦': '…',
    'Â ': ' '
  };

  for (const [bad, good] of Object.entries(fixes)) {
    content = content.split(bad).join(good);
  }

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Fixed:', filePath);
}

// Fix both files
fixEncoding('web/dashboard.html');
fixEncoding('web/article-detail.html');

console.log('Done!');
