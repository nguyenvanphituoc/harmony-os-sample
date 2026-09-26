// WCAG contrast check over the color tokens. Usage: node device-flows/lists-and-open/contrast.mjs
// Text pairs need 4.5, non-text pairs (card border, check box) need 3.0, inkMuted on surfaceDone needs 6.26.
import { readFileSync } from 'node:fs';

const file = new URL('../../app/entry/src/main/resources/base/element/color.json', import.meta.url);
const colors = {};
for (const entry of JSON.parse(readFileSync(file, 'utf8')).color) {
  colors[entry.name] = entry.value;
}

function luminance(hex) {
  const channels = [1, 3, 5].map((i) => {
    const c = parseInt(hex.slice(i, i + 2), 16) / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function ratio(a, b) {
  const la = luminance(colors[a]);
  const lb = luminance(colors[b]);
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

const pairs = [
  ['ink', 'background', 4.5],
  ['ink', 'surface', 4.5],
  ['ink', 'surfaceDone', 4.5],
  ['inkMuted', 'surface', 4.5],
  ['inkMuted', 'surfaceDone', 6.26],
  ['inkMuted', 'background', 4.5],
  ['ink', 'brand', 4.5],
  ['onDanger', 'danger', 4.5],
  ['ink', 'background', 3.0],
  ['ink', 'surface', 3.0],
  ['ink', 'surfaceDone', 3.0]
];

let failed = 0;
for (const [fg, bg, need] of pairs) {
  const got = ratio(fg, bg);
  const ok = got >= need;
  if (!ok) failed += 1;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${fg} on ${bg} ${got.toFixed(2)} (needs ${need})`);
}
process.exit(failed === 0 ? 0 : 1);
