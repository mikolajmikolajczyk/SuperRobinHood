import { useState, useRef } from 'react';
import { SAMPLES } from './pp1/constants';
import { decodeWithSteps } from './pp1/decompress';
import { compressWithSteps } from './pp1/compress';
import type { DecodedResult } from './pp1/types';

import Controls from './components/Controls';
import FileControls from './components/FileControls';
import StatsBar from './components/StatsBar';
import BitstreamPanel from './components/BitstreamPanel';
import ComparisonPanel from './components/ComparisonPanel';
import TilePanel from './components/TilePanel';
import PredictionTable from './components/PredictionTable';
import CompletedTiles from './components/CompletedTiles';
import StepDetails from './components/StepDetails';
import HelpModal from './components/HelpModal';
import LearnModal from './components/LearnModal';

function processData(
  rawData: Uint8Array,
  mode: string,
  isCustom: boolean,
): { decoded: DecodedResult; displayData: Uint8Array } {
  if (mode === 'compress') {
    let tiles: Uint8Array[];
    if (isCustom) {
      tiles = [];
      for (let i = 0; i < rawData.length; i += 16)
        tiles.push(new Uint8Array(rawData.buffer, rawData.byteOffset + i, 16));
    } else {
      const dec = decodeWithSteps(rawData);
      tiles = dec.allTilesChr;
    }
    const decoded = compressWithSteps(tiles);
    return { decoded, displayData: decoded.outputData! };
  } else {
    const decoded = decodeWithSteps(rawData);
    return { decoded, displayData: rawData };
  }
}

function buildResult(dec: DecodedResult, name: string, mode: string) {
  if (mode === 'compress') {
    return { data: dec.outputData!, filename: name + '.pp1' };
  }
  const chrBuf = new Uint8Array(dec.allTilesChr.length * 16);
  dec.allTilesChr.forEach((chr, i) => chrBuf.set(chr, i * 16));
  return { data: chrBuf, filename: name + '.chr' };
}

const INITIAL = processData(SAMPLES.boxchr, 'decompress', false);
const INITIAL_RESULT = buildResult(INITIAL.decoded, 'boxchr', 'decompress');

export default function App() {
  const [mode, setMode] = useState('decompress');
  const [sampleName, setSampleName] = useState('boxchr');
  const [decoded, setDecoded] = useState<DecodedResult>(INITIAL.decoded);
  const [data, setData] = useState<Uint8Array>(INITIAL.displayData);
  const [stepIdx, setStepIdx] = useState(0);
  const [resultData, setResultData] = useState<Uint8Array | null>(INITIAL_RESULT.data);
  const [resultFilename, setResultFilename] = useState(INITIAL_RESULT.filename);
  const [helpOpen, setHelpOpen] = useState(false);
  const [learnOpen, setLearnOpen] = useState(false);

  // Use ref for decoded so callbacks always see latest
  const decodedRef = useRef(decoded);
  decodedRef.current = decoded;

  const step = decoded.steps[stepIdx];

  function load(rawData: Uint8Array, name: string, newMode: string, isCustom: boolean) {
    const { decoded: dec, displayData } = processData(rawData, newMode, isCustom);
    const result = buildResult(dec, name, newMode);
    setDecoded(dec);
    decodedRef.current = dec;
    setData(displayData);
    setStepIdx(0);
    setResultData(result.data);
    setResultFilename(result.filename);
  }

  function handleModeChange(newMode: string) {
    setMode(newMode);
    const sample = SAMPLES[sampleName as keyof typeof SAMPLES];
    if (sample) load(sample, sampleName, newMode, false);
  }

  function handleSampleChange(name: string) {
    setSampleName(name);
    const sample = SAMPLES[name as keyof typeof SAMPLES];
    if (sample) load(sample, name, mode, false);
  }

  function handleFileLoad(fileData: Uint8Array, filename: string) {
    if (mode === 'compress' && fileData.length % 16 !== 0) {
      alert(`Compress mode expects raw CHR tile data (multiple of 16 bytes).\nThis file is ${fileData.length} bytes.`);
      return;
    }
    if (mode === 'decompress' && fileData.length < 2) {
      alert('File too small to be PP1 data.');
      return;
    }
    load(fileData, filename.replace(/\.\w+$/, '') || 'output', mode, true);
  }

  function goTo(idx: number) {
    const steps = decodedRef.current.steps;
    setStepIdx(Math.max(0, Math.min(idx, steps.length - 1)));
  }

  function nextTile() {
    const steps = decodedRef.current.steps;
    setStepIdx(cur => {
      const curTile = steps[cur].tileIndex;
      for (let i = cur + 1; i < steps.length; i++) {
        if (steps[i].tileIndex > curTile || steps[i].type === 'tile-complete') {
          return i;
        }
      }
      return steps.length - 1;
    });
  }

  const isCompress = decoded.mode === 'compress';

  return (
    <>
      <h1 style={{ fontSize: '1.4em', color: 'var(--accent)', marginBottom: 4 }}>
        PP1 Tile Compression <span style={{ color: 'var(--fg2)', fontSize: '0.7em', fontWeight: 'normal' }}>Interactive Demo</span>
      </h1>
      <p className="subtitle">
        Step through Codemasters' NES tile {isCompress ? 'compression' : 'decompression'}, one operation at a time
      </p>

      <div className="intro">
        <strong>How PP1 works:</strong> NES tiles are 8&times;8 pixels, 4 colours (2 bitplanes, 16 bytes each).
        PP1 exploits that consecutive pixels often repeat or follow predictable patterns.
        Instead of storing raw pixel values, it encodes <em>which transition</em> occurred
        (e.g. "same colour" or "switch to follower #1"). A per-tile <strong>header</strong> defines
        the prediction tables, and 8 <strong>scanlines</strong> are decoded using those tables.
        Click <strong>?</strong> for the full format reference.
      </div>

      <Controls
        mode={mode}
        sampleName={sampleName}
        stepIdx={stepIdx}
        totalSteps={decoded.steps.length}
        onModeChange={handleModeChange}
        onSampleChange={handleSampleChange}
        onGoTo={goTo}
        onNextTile={nextTile}
        onHelp={() => setHelpOpen(true)}
        onLearn={() => setLearnOpen(true)}
      />

      <FileControls
        resultData={resultData}
        resultFilename={resultFilename}
        onFileLoad={handleFileLoad}
      />

      <StatsBar decoded={decoded} step={step} />

      <div className="main">
        <div className="left-col">
          {isCompress ? (
            <>
              <div className="panel" style={{ marginBottom: 12 }}>
                <h2>CHR Input vs PP1 Output</h2>
                <ComparisonPanel decoded={decoded} data={data} step={step} />
              </div>
              <div className="panel" style={{ marginBottom: 12 }}>
                <h2>Output Bitstream</h2>
                <BitstreamPanel data={data} step={step} totalBits={decoded.totalBits} isCompress />
              </div>
            </>
          ) : (
            <>
              <div className="panel" style={{ marginBottom: 12 }}>
                <h2>Bitstream</h2>
                <BitstreamPanel data={data} step={step} totalBits={decoded.totalBits} />
              </div>
              <div className="panel" style={{ marginBottom: 12 }}>
                <h2>Compressed vs Decoded</h2>
                <ComparisonPanel decoded={decoded} data={data} step={step} />
              </div>
            </>
          )}
          <div className="panel">
            <h2>Step Details</h2>
            <StepDetails step={step} />
          </div>
        </div>
        <div className="right-col">
          <div className="panel" style={{ marginBottom: 12 }}>
            <h2>Current Tile</h2>
            <TilePanel step={step} />
          </div>
          <div className="panel" style={{ marginBottom: 12 }}>
            <h2>Prediction Table</h2>
            <PredictionTable header={step.header} highlightX={step.headerHighlight} />
          </div>
          <div className="panel">
            <h2>Completed Tiles</h2>
            <CompletedTiles allTiles={decoded.allTiles} count={step.completedCount} />
          </div>
        </div>
      </div>

      <div className="panel" style={{ marginTop: 16 }}>
        <h2>Bitplanes</h2>
        <TilePanel step={step} bitplanesOnly />
      </div>

      <HelpModal open={helpOpen} onClose={() => setHelpOpen(false)} />
      <LearnModal open={learnOpen} onClose={() => setLearnOpen(false)} />
    </>
  );
}
