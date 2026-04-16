import { PALETTE } from '../pp1/constants';
import { bpFromPixels } from '../pp1/decompress';
import type { Step } from '../pp1/types';

interface TilePanelProps {
  step: Step;
  bitplanesOnly?: boolean;
}

const TilePanel: React.FC<TilePanelProps> = ({ step, bitplanesOnly }) => {
  const tile = step.currentTile; // 8 rows of 8 pixels (number[][])
  const highlightSet = new Set(
    step.highlightPixels.map((p) => `${p.r},${p.c}`)
  );

  if (bitplanesOnly) {
    return (
      <div className="bitplanes">
        <div className="bp-layout">
          {renderBitplaneSection(tile, 0, 'Bitplane 0 (low bit)', step.highlightRow)}
          <div className="bp-plus">+</div>
          {renderBitplaneSection(tile, 1, 'Bitplane 1 (high bit)', step.highlightRow)}
          <div className="bp-equals">=</div>
          {renderCombinedSection(tile, step.highlightRow)}
        </div>
        <div className="bp-explanation">
          NES CHR: bytes 0–7 = bp0 (rows top→bottom), bytes 8–15 = bp1 — <strong>64 bits apart!</strong><br/>
          Pixel = <span className="c0">■0</span> (both off){' '}
          <span className="c1">■1</span> (bp0 only){' '}
          <span className="c2">■2</span> (bp1 only){' '}
          <span className="c3">■3</span> (both on)
        </div>
      </div>
    );
  }

  return (
    <div className="tile-area">
      <div className="current-tile-grid">
        {tile.map((row, r) =>
          row.map((px, c) => {
            const filled = px >= 0;
            const isHighlight = highlightSet.has(`${r},${c}`);
            const isScanlineHl = r === step.highlightRow;
            const cls = ['px',
              !filled && 'unfilled',
              isHighlight && 'highlight',
              isScanlineHl && 'scanline-hl',
            ].filter(Boolean).join(' ');
            return (
              <div
                key={`${r}-${c}`}
                className={cls}
                style={filled ? { backgroundColor: PALETTE[px & 3] } : undefined}
              />
            );
          })
        )}
      </div>
      <div style={{ fontFamily: 'monospace', fontSize: '0.8em', color: 'var(--fg2)', marginTop: 4 }}>
        {step.tileIndex >= 0 ? `Tile ${step.tileIndex} of ${step.completedCount + (step.type === 'tile-complete' ? 0 : 1)}` : ''}
      </div>
      <div style={{ fontFamily: 'monospace', fontSize: '0.72em', color: 'var(--fg2)', marginTop: 6, display: 'flex', gap: 12, justifyContent: 'center' }}>
        <span><span style={{ display: 'inline-block', width: 10, height: 10, border: '2px solid var(--yellow)', verticalAlign: 'middle', marginRight: 3 }} /> pixels decoded this step</span>
        <span><span style={{ display: 'inline-block', width: 10, height: 10, border: '1px solid var(--accent)', verticalAlign: 'middle', marginRight: 3 }} /> current scanline</span>
        <span><span style={{ display: 'inline-block', width: 10, height: 10, background: '#222', verticalAlign: 'middle', marginRight: 3 }} /> not yet decoded</span>
      </div>
    </div>
  );
};

function renderBitplaneSection(
  tile: number[][],
  plane: number,
  label: string,
  highlightRow: number
) {
  const byteBase = plane * 8;
  return (
    <div className="bitplane-section">
      <h4>{label}</h4>
      {tile.map((row, r) => {
        const filled = row[0] >= 0;
        const bpByte = filled ? bpFromPixels(row, plane) : 0;
        return (
          <div
            key={r}
            className={`bitplane-row${r === highlightRow ? ' highlight-row' : ''}`}
          >
            <span className="bp-idx">[{String(byteBase + r).padStart(2, '\u00a0')}]</span>
            <span className="bp-bits">
              {row.map((px, c) => {
                if (px < 0) return <span key={c} className="bit-unfilled">-</span>;
                const bit = (px >> plane) & 1;
                return <span key={c} className={bit ? `bit-on-${plane}` : 'bit-off'}>{bit}</span>;
              })}
            </span>
            <span className="bp-hex">
              {filled ? bpByte.toString(16).padStart(2, '0') : '--'}
            </span>
          </div>
        );
      })}
    </div>
  );
}

function renderCombinedSection(tile: number[][], highlightRow: number) {
  return (
    <div className="bitplane-section">
      <h4>Combined (2-bit)</h4>
      {tile.map((row, r) => {
        const filled = row[0] >= 0;
        return (
          <div
            key={r}
            className={`bitplane-row${r === highlightRow ? ' highlight-row' : ''}`}
          >
            <span className="bp-bits">
              {row.map((px, c) => {
                if (px < 0) return <span key={c} className="bit-unfilled">-</span>;
                return <span key={c} className={`cpx-${px & 3}`}>{px & 3}</span>;
              })}
            </span>
          </div>
        );
      })}
    </div>
  );
}

export default TilePanel;
