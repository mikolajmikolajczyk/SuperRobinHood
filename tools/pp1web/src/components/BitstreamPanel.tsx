import type { Step } from '../pp1/types';

interface BitstreamPanelProps {
  data: Uint8Array;
  step: Step;
  totalBits: number;
  isCompress?: boolean;
}

function renderBitstreamHex(data: Uint8Array, step: Step, totalBits: number, isCompress: boolean): string {
  const startBit = step.bitStart;
  const endBit = step.bitEnd;
  // totalBits is absolute bit position (bitstream starts at byte 1 = bit 8)
  const bitstreamBits = totalBits - 8;
  const usedBytes = 1 + Math.ceil(bitstreamBits / 8);

  // In compress mode, only show bytes written so far (up to endBit)
  const writtenBytes = isCompress ? Math.ceil(endBit / 8) : data.length;

  const startByte = Math.floor(startBit / 8);
  const endByte = Math.ceil(endBit / 8);

  // Window around current position
  const winStart = Math.max(0, startByte - 16);
  const winEnd = Math.min(writtenBytes, endByte + 48);

  if (isCompress && winEnd === 0) {
    return '<span style="color:var(--fg2)">Output bitstream builds here as tiles are encoded...</span>';
  }

  let html = '';
  for (let i = winStart; i < winEnd; i++) {
    const hex = data[i].toString(16).padStart(2, '0');
    const byteStartBit = i * 8;
    const byteEndBit = byteStartBit + 8;
    let cls = 'byte-';
    if (byteEndBit <= startBit) cls += 'consumed';
    else if (byteStartBit >= endBit) cls += 'future';
    else cls += 'current';
    html += `<span class="${cls}">${hex}</span> `;
    if ((i - winStart) % 16 === 15) html += '\n';
  }

  if (isCompress) {
    const totalOutput = Math.ceil(endBit / 8);
    html += `\n<span style="color:var(--fg2);font-size:0.85em">  ─── ${totalOutput} byte${totalOutput !== 1 ? 's' : ''} written so far ───</span>`;
  } else {
    // Decompress: mark unused trailing bytes
    for (let i = winEnd; i < Math.min(data.length, endByte + 48); i++) {
      const hex = data[i].toString(16).padStart(2, '0');
      if (i >= usedBytes) {
        html += `<span class="byte-unused">${hex}</span> `;
      } else {
        html += `<span class="byte-future">${hex}</span> `;
      }
      if ((i - winStart) % 16 === 15) html += '\n';
    }
    if (data.length > usedBytes) {
      html += `\n<span style="color:var(--fg2);font-size:0.85em">  ─── ${data.length - usedBytes} trailing byte${data.length - usedBytes > 1 ? 's' : ''} not part of PP1 stream ───</span>`;
    }
  }
  return html;
}

function renderBitDetail(data: Uint8Array, step: Step): string {
  const startBit = step.bitStart;
  const endBit = step.bitEnd;
  if (startBit === endBit) {
    return '<span style="color:var(--fg2);font-size:0.8em">No bits consumed in this step</span>';
  }

  // Show bytes around the current bits
  const startByte = Math.floor(startBit / 8);
  const showStart = Math.max(0, startByte);
  const showEnd = Math.min(data.length, Math.ceil(endBit / 8) + 1);

  let html = '';
  for (let byteIdx = showStart; byteIdx < showEnd; byteIdx++) {
    const b = data[byteIdx];
    html += `<span style="color:var(--fg2);font-size:0.8em">0x${b.toString(16).padStart(2, '0')}: </span>`;
    for (let bit = 0; bit < 8; bit++) {
      const globalBit = byteIdx * 8 + bit;
      const v = (b >> (7 - bit)) & 1;
      let cls: string;
      if (globalBit < startBit) cls = 'bit-consumed';
      else if (globalBit >= endBit) cls = 'bit-future';
      else cls = 'bit-current';
      html += `<span class="${cls}">${v}</span>`;
    }
    html += '  ';
  }

  // Show the consumed bits summary
  let consumed = '';
  for (let i = startBit; i < endBit; i++) {
    const byteIdx = Math.floor(i / 8);
    const bitIdx = i % 8;
    const b = byteIdx < data.length ? data[byteIdx] : 0;
    consumed += ((b >> (7 - bitIdx)) & 1).toString();
  }
  if (consumed) {
    html += `\n<span style="color:var(--fg2);font-size:0.8em">Bits read: </span><span class="bit-current">${consumed}</span>`;
    html += ` <span style="color:var(--fg2);font-size:0.8em">(${endBit - startBit} bit${endBit - startBit > 1 ? 's' : ''})</span>`;
  }
  return html;
}

const BitstreamPanel: React.FC<BitstreamPanelProps> = ({ data, step, totalBits, isCompress }) => {
  return (
    <>
      <div
        className="bitstream-hex"
        dangerouslySetInnerHTML={{ __html: renderBitstreamHex(data, step, totalBits, !!isCompress) }}
      />
      <div
        className="bit-detail"
        dangerouslySetInnerHTML={{ __html: renderBitDetail(data, step) }}
      />
    </>
  );
};

export default BitstreamPanel;
