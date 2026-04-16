import { useRef, useEffect } from 'react';
import type { DecodedResult, Step } from '../pp1/types';
import { bpFromPixels } from '../pp1/decompress';

interface ComparisonPanelProps {
  decoded: DecodedResult;
  data: Uint8Array;
  step: Step;
}

function chrHex(chr: Uint8Array): string {
  let bp0 = '', bp1 = '';
  for (let i = 0; i < 8; i++) bp0 += chr[i].toString(16).padStart(2, '0') + ' ';
  for (let i = 8; i < 16; i++) bp1 += chr[i].toString(16).padStart(2, '0') + ' ';
  return `${bp0.trim()} <span style="color:#333">|</span> ${bp1.trim()}`;
}

function compressedHex(data: Uint8Array, bitRange: { start: number; end: number }, maxShow: number) {
  const startByte = Math.floor(bitRange.start / 8);
  const endByte = Math.ceil(bitRange.end / 8);
  const bytes: string[] = [];
  for (let i = startByte; i < endByte && i < data.length; i++)
    bytes.push(data[i].toString(16).padStart(2, '0'));
  const total = bytes.length;
  if (total <= maxShow) return { text: bytes.join(' '), total };
  return { text: bytes.slice(0, maxShow - 1).join(' ') + ' ..', total };
}

function renderOutput(decoded: DecodedResult, data: Uint8Array, step: Step): string {
  const { allTilesChr, tileBitRanges, tileCount, mode } = decoded;
  const isCompress = mode === 'compress';
  const completedCount = step.completedCount;
  const currentTileIdx = step.tileIndex;

  // Column headers
  let html = '<div style="display:flex;gap:0;color:var(--fg2);font-size:0.9em;padding-bottom:4px;border-bottom:1px solid #333;margin-bottom:2px">';
  html += '<span style="min-width:36px;text-align:right;padding-right:8px">Tile</span>';
  if (isCompress) {
    html += '<span style="flex:1">CHR input (bp0 | bp1)</span>';
    html += '<span style="padding:0 6px"> </span>';
    html += '<span style="min-width:140px">PP1 output</span>';
  } else {
    html += '<span style="min-width:140px">PP1 bytes</span>';
    html += '<span style="padding:0 6px"> </span>';
    html += '<span style="flex:1">CHR output (bp0 | bp1)</span>';
  }
  html += '<span style="min-width:64px;text-align:right;padding-left:8px">Ratio</span>';
  html += '</div>';

  // Window around current tile
  const winStart = Math.max(0, currentTileIdx - 5);
  const winEnd = Math.min(tileCount, winStart + 30);

  if (winStart > 0)
    html += `<div style="color:var(--fg2);padding:2px 0;font-size:0.9em">  ... ${winStart} tile${winStart > 1 ? 's' : ''} above ...</div>`;

  for (let i = winStart; i < winEnd; i++) {
    const isCurrent = i === currentTileIdx;
    const isFuture = !isCompress && i >= completedCount;
    const bg = isCurrent ? 'background:rgba(79,195,247,0.08);' : '';
    const opacity = isFuture ? 'opacity:0.25;' : '';
    const idxStyle = isCurrent ? 'color:var(--accent);font-weight:bold' : 'color:var(--fg2)';

    html += `<div style="display:flex;gap:0;align-items:baseline;padding:2px 0;border-bottom:1px solid #1a1a2e;${bg}${opacity}">`;
    html += `<span style="min-width:36px;text-align:right;padding-right:8px;${idxStyle};flex-shrink:0">${i}</span>`;

    if (isCompress) {
      // CHR is always known (input), PP1 builds progressively
      const chr = allTilesChr[i];
      const chrStr = chr ? chrHex(chr) : '-- -- -- -- -- -- -- -- | -- -- -- -- -- -- -- --';

      if (i < completedCount) {
        const range = tileBitRanges[i];
        const compBits = range.end - range.start;
        const compBytes = compBits / 8;
        const comp = compressedHex(data, range, 6);
        html += `<span style="flex:1;color:var(--green)">${chrStr}</span>`;
        html += `<span style="padding:0 6px;color:var(--fg2)">→</span>`;
        html += `<span style="min-width:140px;color:var(--accent)" title="${comp.total} bytes, ${compBits} bits">${comp.text}</span>`;
        html += `<span style="min-width:64px;text-align:right;padding-left:8px;color:var(--fg2)">16→${compBytes.toFixed(1)}</span>`;
      } else if (i === currentTileIdx) {
        html += `<span style="flex:1;color:var(--green)">${chrStr}</span>`;
        html += `<span style="padding:0 6px;color:var(--fg2)">→</span>`;
        html += `<span style="min-width:140px;color:#555;font-style:italic">encoding...</span>`;
        html += `<span style="min-width:64px"></span>`;
      } else {
        html += `<span style="flex:1;color:var(--green)">${chrStr}</span>`;
        html += `<span style="padding:0 6px"> </span>`;
        html += `<span style="min-width:140px;color:#555;font-style:italic">pending</span>`;
        html += `<span style="min-width:64px"></span>`;
      }
    } else {
      // Decompress: PP1 is known (input), CHR builds progressively
      if (i < completedCount) {
        const range = tileBitRanges[i];
        const compBits = range.end - range.start;
        const compBytes = compBits / 8;
        const comp = compressedHex(data, range, 6);
        const chr = allTilesChr[i];
        html += `<span style="min-width:140px;color:var(--accent);flex-shrink:0" title="${comp.total} bytes, ${compBits} bits">${comp.text}</span>`;
        html += `<span style="padding:0 6px;color:var(--fg2)">→</span>`;
        html += `<span style="flex:1;color:var(--green)">${chrHex(chr)}</span>`;
        html += `<span style="min-width:64px;text-align:right;padding-left:8px;color:var(--fg2)">${compBytes.toFixed(1)}→16</span>`;
      } else if (i === currentTileIdx && currentTileIdx >= 0) {
        const tile = step.currentTile;
        const hasData = tile.some(row => row.some(v => v >= 0));
        if (hasData) {
          const chr = new Uint8Array(16);
          for (let r = 0; r < 8; r++) {
            if (tile[r][0] < 0) continue;
            chr[r] = bpFromPixels(tile[r], 0);
            chr[r + 8] = bpFromPixels(tile[r], 1);
          }
          const filledRows = tile.filter(row => row[0] >= 0).length;
          html += `<span style="min-width:140px;color:#555;font-style:italic;flex-shrink:0">decoding...</span>`;
          html += `<span style="padding:0 6px;color:var(--fg2)">→</span>`;
          html += `<span style="flex:1;color:var(--green)">${chrHex(chr)}</span>`;
          html += `<span style="min-width:64px;text-align:right;padding-left:8px;color:#555;font-style:italic">${filledRows}/8 rows</span>`;
        } else {
          html += `<span style="min-width:140px;color:#555;font-style:italic;flex-shrink:0">reading header...</span>`;
          html += `<span style="padding:0 6px"> </span>`;
          html += `<span style="flex:1;color:#555">-- -- -- -- -- -- -- -- | -- -- -- -- -- -- -- --</span>`;
          html += `<span style="min-width:64px"></span>`;
        }
      } else {
        html += `<span style="min-width:140px;color:#555;flex-shrink:0">?</span>`;
        html += `<span style="padding:0 6px"> </span>`;
        html += `<span style="flex:1;color:#555">-- -- -- -- -- -- -- -- | -- -- -- -- -- -- -- --</span>`;
        html += `<span style="min-width:64px"></span>`;
      }
    }
    html += '</div>';
  }

  if (winEnd < tileCount)
    html += `<div style="color:var(--fg2);padding:2px 0;font-size:0.9em">  ... ${tileCount - winEnd} more tile${tileCount - winEnd > 1 ? 's' : ''} below ...</div>`;

  return html;
}

const ComparisonPanel: React.FC<ComparisonPanelProps> = ({ decoded, data, step }) => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Scroll current tile into view
    const el = containerRef.current?.querySelector('[style*="accent"]');
    if (el) (el as HTMLElement).scrollIntoView({ block: 'nearest' });
  });

  return (
    <div
      ref={containerRef}
      className="decoded-output"
      style={{
        fontFamily: "'JetBrains Mono','Fira Code',monospace",
        fontSize: '0.78em', lineHeight: 1.6,
        maxHeight: 200, overflowY: 'auto',
        padding: 8, background: '#0d0d1a', borderRadius: 4,
      }}
      dangerouslySetInnerHTML={{ __html: renderOutput(decoded, data, step) }}
    />
  );
};

export default ComparisonPanel;
