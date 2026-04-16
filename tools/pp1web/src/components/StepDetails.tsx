import type { Step } from '../pp1/types';

interface StepDetailsProps {
  step: Step;
}

function escHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function highlightDetail(detail: string): string {
  let html = escHtml(detail);
  // Bit strings in quotes: bit '01', bits '110'
  html = html.replace(/(bit[s]?\s+&#39;)([01]+)(&#39;)/g,
    '$1<span class="val-bits">$2</span>$3');
  // Values after arrows: → 3
  html = html.replace(/(→\s*)(\d+)/g,
    '$1<span class="val-num">$2</span>');
  // Values after equals: = 3
  html = html.replace(/(=\s*)(\d+)/g,
    '$1<span class="val-num">$2</span>');
  // Hex values: 0xFF
  html = html.replace(/(0x[0-9a-f]+)/gi,
    '<span class="val-hex">$1</span>');
  return html;
}

const StepDetails: React.FC<StepDetailsProps> = ({ step }) => {
  return (
    <>
      <div className="step-details">
        <span className="step-title">{step.title}</span>
        <div
          className="step-desc"
          dangerouslySetInnerHTML={{ __html: highlightDetail(step.detail) }}
        />
      </div>
    </>
  );
};

export default StepDetails;
