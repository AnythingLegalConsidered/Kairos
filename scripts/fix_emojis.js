const fs = require('fs');

function fixEmojis(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Fix broken emoji encodings
  content = content.replace(/ðŸ•/g, '🕐');
  content = content.replace(/ðŸ"‚/g, '📂');
  content = content.replace(/ðŸ"„/g, '📄');
  content = content.replace(/ðŸ"‹/g, '📋');
  content = content.replace(/ðŸ—'/g, '🗑');
  content = content.replace(/ðŸ"­/g, '🔭');
  content = content.replace(/ðŸ"¥/g, '📥');
  content = content.replace(/âœ"/g, '✓');
  content = content.replace(/â—‹/g, '○');

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Fixed:', filePath);
}

fixEmojis('web/dashboard.html');
fixEmojis('web/article-detail.html');
console.log('Done!');
