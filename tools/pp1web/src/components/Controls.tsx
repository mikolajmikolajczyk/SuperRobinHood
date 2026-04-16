import { useEffect } from 'react';

interface ControlsProps {
  mode: string;
  sampleName: string;
  stepIdx: number;
  totalSteps: number;
  onModeChange: (mode: string) => void;
  onSampleChange: (name: string) => void;
  onGoTo: (idx: number) => void;
  onNextTile: () => void;
  onHelp: () => void;
  onLearn: () => void;
}

const Controls: React.FC<ControlsProps> = ({
  mode,
  sampleName,
  stepIdx,
  totalSteps,
  onModeChange,
  onSampleChange,
  onGoTo,
  onNextTile,
  onHelp,
  onLearn,
}) => {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLSelectElement) return;
      switch (e.key) {
        case 'ArrowLeft':
          e.preventDefault();
          onGoTo(stepIdx - 1);
          break;
        case 'ArrowRight':
        case ' ':
          e.preventDefault();
          onGoTo(stepIdx + 1);
          break;
        case 'ArrowDown':
          e.preventDefault();
          onNextTile();
          break;
        case 'Home':
          e.preventDefault();
          onGoTo(0);
          break;
        case 'End':
          e.preventDefault();
          onGoTo(totalSteps - 1);
          break;
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [stepIdx, totalSteps, onGoTo, onNextTile]);

  return (
    <div className="controls">
      <label>Mode:</label>
      <select value={mode} onChange={(e) => onModeChange(e.target.value)}>
        <option value="decompress">Decompress</option>
        <option value="compress">Compress</option>
      </select>

      <label>Sample:</label>
      <select value={sampleName} onChange={(e) => onSampleChange(e.target.value)}>
        <option value="boxchr">boxchr (9 tiles, 46 bytes)</option>
        <option value="beadchr">beadchr (23 tiles, 213 bytes)</option>
        <option value="okchr">okchr (1 tile, 15 bytes)</option>
        <option value="hiscorechrs">hiscorechrs (200 tiles, 1402 bytes)</option>
      </select>

      <div className="spacer" />
      <div className="nav-group">
        <button onClick={() => onGoTo(0)} disabled={stepIdx <= 0} title="First step (Home)">
          |&laquo;
        </button>
        <button onClick={() => onGoTo(stepIdx - 1)} disabled={stepIdx <= 0} title="Previous step (&larr;)">
          &laquo; Prev
        </button>
        <span className="step-counter">
          {stepIdx + 1} / {totalSteps}
        </span>
        <button onClick={() => onGoTo(stepIdx + 1)} disabled={stepIdx >= totalSteps - 1} title="Next step (&rarr; / Space)">
          Next &raquo;
        </button>
        <button onClick={onNextTile} disabled={stepIdx >= totalSteps - 1} title="Next tile (&darr;)">
          Tile &raquo;&raquo;
        </button>
        <button onClick={() => onGoTo(totalSteps - 1)} disabled={stepIdx >= totalSteps - 1} title="Last step (End)">
          &raquo;|
        </button>
      </div>

      <button className="help-btn" onClick={onLearn} title="Learn about pixel prediction" style={{ fontSize: '0.85em' }}>
        &#x1F4D6;
      </button>
      <button className="help-btn" onClick={onHelp} title="PP1 format reference">
        ?
      </button>
    </div>
  );
};

export default Controls;
