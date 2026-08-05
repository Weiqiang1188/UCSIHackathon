// Render the CyLab Academy page with Puppeteer + system Chrome
import puppeteer from 'puppeteer-core';

const url = process.argv[2] || 'https://learn.cylabacademy.org/library/478?page=1&category=1&difficulty=3';
const outfile = process.argv[3] || '/tmp/rendered.html';

const browser = await puppeteer.launch({
  executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  headless: 'new',
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage',
    '--disable-blink-features=AutomationControlled',
  ],
});
try {
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36');
  await page.setExtraHTTPHeaders({ 'Accept-Language': 'en-US,en;q=0.9' });
  console.log('Navigating...');
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });
  // Wait for SPA to render challenge list
  await new Promise(r => setTimeout(r, 5000));
  const html = await page.content();
  const fs = await import('fs');
  fs.writeFileSync(outfile, html);
  console.log(`Saved ${html.length} bytes to ${outfile}`);
  // Also extract challenge titles/links visible on the page
  const data = await page.evaluate(() => {
    const out = { title: document.title, url: location.href, links: [], text: '' };
    document.querySelectorAll('a').forEach(a => {
      const href = a.getAttribute('href');
      if (href) out.links.push({ href, text: a.innerText.trim().slice(0, 100) });
    });
    out.text = document.body.innerText.slice(0, 4000);
    return out;
  });
  const fs2 = await import('fs');
  fs2.writeFileSync(outfile + '.json', JSON.stringify(data, null, 2));
  console.log('Title:', data.title);
  console.log('Links found:', data.links.length);
  console.log('--- Text preview ---');
  console.log(data.text);
} finally {
  await browser.close();
}
