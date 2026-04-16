import { useRef, useEffect } from 'react';
import { PALETTE_RGB } from '../pp1/constants';

interface CompletedTilesProps {
  allTiles: number[][][];
  count: number;
}

const TILE_DISPLAY_SIZE = 24; // pixels per canvas (8x8 upscaled 3x)

const CompletedTiles: React.FC<CompletedTilesProps> = ({ allTiles, count }) => {
  const canvasRefs = useRef<(HTMLCanvasElement | null)[]>([]);

  useEffect(() => {
    for (let t = 0; t < count; t++) {
      const canvas = canvasRefs.current[t];
      if (!canvas) continue;
      const ctx = canvas.getContext('2d');
      if (!ctx) continue;

      const tile = allTiles[t];
      if (!tile) continue;

      const img = ctx.createImageData(8, 8);
      for (let r = 0; r < 8; r++) {
        for (let c = 0; c < 8; c++) {
          const px = tile[r]?.[c] ?? 0;
          const [red, green, blue] = PALETTE_RGB[px & 3];
          const idx = (r * 8 + c) * 4;
          img.data[idx] = red;
          img.data[idx + 1] = green;
          img.data[idx + 2] = blue;
          img.data[idx + 3] = 255;
        }
      }
      ctx.putImageData(img, 0, 0);
    }
  }, [allTiles, count]);

  return (
    <div className="completed-tiles">
      {Array.from({ length: count }, (_, t) => (
        <canvas
          key={t}
          ref={(el) => { canvasRefs.current[t] = el; }}
          width={8}
          height={8}
          style={{ width: 32, height: 32 }}
          title={`Tile #${t}`}
        />
      ))}
    </div>
  );
};

export default CompletedTiles;
