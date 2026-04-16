import { useRef } from 'react';
import { CC65_UNPACKER_SRC } from '../pp1/cc65';

interface FileControlsProps {
  resultData: Uint8Array | null;
  resultFilename: string;
  onFileLoad: (data: Uint8Array, name: string) => void;
}

function downloadBlob(data: Uint8Array | string, filename: string, mime: string) {
  const blobData: BlobPart = typeof data === 'string' ? data : data.slice().buffer;
  const blob = new Blob(
    [blobData],
    { type: mime }
  );
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

const FileControls: React.FC<FileControlsProps> = ({
  resultData,
  resultFilename,
  onFileLoad,
}) => {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFile = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const arr = new Uint8Array(reader.result as ArrayBuffer);
      onFileLoad(arr, file.name);
    };
    reader.readAsArrayBuffer(file);
  };

  return (
    <div className="file-controls">
      <label>Load file:</label>
      <input
        ref={inputRef}
        type="file"
        accept=".chr,.bin,.pp1,.dat,.raw"
        onChange={handleFile}
      />
      <button
        disabled={!resultData}
        onClick={() => {
          if (resultData) downloadBlob(resultData, resultFilename, 'application/octet-stream');
        }}
      >
        {resultFilename ? `Download ${resultFilename}` : 'Download Result'}
      </button>
      <div className="spacer" />
      <button
        onClick={() => downloadBlob(CC65_UNPACKER_SRC, 'pp1_unpack.s', 'text/plain')}
        title="Download ca65 PP1 decompressor source"
      >
        Download cc65 Unpacker (.s)
      </button>
    </div>
  );
};

export default FileControls;
