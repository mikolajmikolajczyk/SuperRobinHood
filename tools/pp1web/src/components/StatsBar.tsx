import type { DecodedResult, Step } from '../pp1/types';

interface StatsBarProps {
  decoded: DecodedResult;
  step: Step;
}

const StatsBar: React.FC<StatsBarProps> = ({ decoded, step }) => {
  const tileCount = decoded.tileCount;
  const uncompressedBytes = tileCount * 16;
  const bitstreamBits = decoded.totalBits - 8;
  const compressedBytes = 1 + Math.ceil(bitstreamBits / 8);

  // Current consumed bytes at this step
  const consumedBits = step.bitEnd;
  const currentBitstreamBits = Math.max(0, consumedBits - 8);
  const currentBytes = 1 + Math.ceil(currentBitstreamBits / 8);

  const pctCompressed = (compressedBytes / uncompressedBytes * 100);
  const pctConsumed = (currentBytes / uncompressedBytes * 100);
  const ratio = (compressedBytes / uncompressedBytes * 100).toFixed(1);
  const saved = uncompressedBytes - compressedBytes;

  return (
    <div className="stats-bar">
      <h2>Compression</h2>
      <div className="bar-row">
        <span className="bar-label">Uncompressed</span>
        <div className="bar-track">
          <div className="bar-fill uncompressed" style={{ width: '100%' }} />
        </div>
        <span className="bar-value">{uncompressedBytes} bytes</span>
      </div>
      <div className="bar-row">
        <span className="bar-label">PP1 stream</span>
        <div className="bar-track">
          <div className="bar-fill pp1-stream" style={{ width: `${Math.min(pctCompressed, 100)}%` }} />
        </div>
        <span className="bar-value">{compressedBytes} bytes</span>
      </div>
      <div className="bar-row">
        <span className="bar-label">Consumed</span>
        <div className="bar-track">
          <div className="bar-fill consumed" style={{ width: `${Math.min(pctConsumed, 100)}%` }} />
        </div>
        <span className="bar-value">{currentBytes} bytes</span>
      </div>
      <div className="stats-summary">
        {tileCount} tiles &times; 16 bytes ={' '}
        <span style={{ color: 'var(--accent)', fontWeight: 'bold' }}>{uncompressedBytes}</span> bytes uncompressed
        {' '}&rarr;{' '}
        <span style={{ color: 'var(--accent)', fontWeight: 'bold' }}>{compressedBytes}</span> bytes PP1
        {' '}(<span style={{ color: 'var(--accent)', fontWeight: 'bold' }}>{ratio}%</span>)
        {' '}&mdash;{' '}
        <span style={{ color: 'var(--green)' }}>{saved} bytes saved</span>
      </div>
    </div>
  );
};

export default StatsBar;
