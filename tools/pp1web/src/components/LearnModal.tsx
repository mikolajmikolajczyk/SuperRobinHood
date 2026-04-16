interface LearnModalProps {
  open: boolean;
  onClose: () => void;
}

const overlay: React.CSSProperties = {
  position: 'fixed', inset: 0, zIndex: 1000,
  background: 'rgba(0,0,0,0.75)', backdropFilter: 'blur(3px)',
  display: 'flex', justifyContent: 'center', alignItems: 'flex-start',
  padding: '30px 16px', overflowY: 'auto',
};
const modal: React.CSSProperties = {
  background: '#16213e', borderRadius: 12, maxWidth: 900, width: '100%',
  padding: '28px 32px', position: 'relative', border: '1px solid #333',
  boxShadow: '0 8px 40px rgba(0,0,0,0.6)', color: '#e0e0e0',
  fontFamily: "'Segoe UI', system-ui, sans-serif", fontSize: '0.95em', lineHeight: 1.7,
};
const closeBtn: React.CSSProperties = {
  position: 'absolute', top: 12, right: 16, background: 'none', border: 'none',
  color: '#999', fontSize: '1.8em', cursor: 'pointer', lineHeight: 1,
};
const h2: React.CSSProperties = { color: '#4fc3f7', margin: '28px 0 10px', fontSize: '1.25em' };
const h3: React.CSSProperties = { color: '#66bb6a', margin: '18px 0 6px', fontSize: '1.05em' };
const pre: React.CSSProperties = {
  background: '#0d0d1a', padding: 14, borderRadius: 6, overflowX: 'auto',
  fontFamily: "'JetBrains Mono','Fira Code',monospace", fontSize: '0.85em',
  lineHeight: 1.6, margin: '8px 0',
};
const note: React.CSSProperties = {
  background: 'rgba(79,195,247,0.08)', borderLeft: '3px solid #4fc3f7',
  padding: '8px 12px', borderRadius: '0 4px 4px 0', margin: '10px 0', fontSize: '0.92em',
};
const tbl: React.CSSProperties = {
  borderCollapse: 'collapse', width: '100%', margin: '8px 0',
  fontFamily: 'monospace', fontSize: '0.88em',
};
const th: React.CSSProperties = { color: '#4fc3f7', textAlign: 'left', padding: '4px 10px', borderBottom: '1px solid #444' };
const td: React.CSSProperties = { padding: '4px 10px', borderBottom: '1px solid #222' };
const acc: React.CSSProperties = { color: '#4fc3f7' };
const grn: React.CSSProperties = { color: '#66bb6a' };

const LearnModal: React.FC<LearnModalProps> = ({ open, onClose }) => {
  if (!open) return null;

  return (
    <div style={overlay} onClick={onClose}>
      <div style={modal} onClick={e => e.stopPropagation()}>
        <button style={closeBtn} onClick={onClose}>&times;</button>

        <h1 style={{ color: '#4fc3f7', margin: 0, fontSize: '1.4em' }}>
          &#x1F4D6; Introduction to Pixel Prediction
        </h1>
        <p style={{ color: '#999' }}>
          How do computers make images smaller? A beginner-friendly guide to the ideas behind
          image compression — no math degree required!
        </p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={{...h2, marginTop: 16}}>What is Compression?</h2>

<p>
  Imagine you need to describe this row of coloured blocks to someone in a text message:
</p>

<pre style={pre}>{`🟥🟥🟥🟥🟥🟦🟦🟦`}</pre>

<p>
  You <em>could</em> list every block: "red, red, red, red, red, blue, blue, blue"
  — that's 8 items. But you'd probably just say <strong>"5 reds, then 3 blues"</strong>
  — only 2 items! Same information, less space. That's compression.
</p>

<p>
  There are many ways to compress things. Here are the big families:
</p>

<table style={tbl}>
  <thead>
    <tr><th style={th}>Method</th><th style={th}>Idea</th><th style={th}>Example</th></tr>
  </thead>
  <tbody>
    <tr><td style={td}>Run-length</td><td style={td}>Count repeated items</td><td style={td}>"5 red, 3 blue"</td></tr>
    <tr><td style={td}>Dictionary</td><td style={td}>Build a codebook of patterns</td><td style={td}>ZIP, LZ77</td></tr>
    <tr><td style={td}>Entropy coding</td><td style={td}>Use shorter codes for common things</td><td style={td}>Huffman, arithmetic</td></tr>
    <tr><td style={{...td,...acc}}>Prediction</td><td style={{...td,...acc}}>Guess the next value, encode the surprise</td><td style={{...td,...acc}}>PP1, PNG filters</td></tr>
  </tbody>
</table>

<p>
  PP1 uses <strong>prediction</strong> — and that's what this guide is all about.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>The Prediction Trick</h2>

<p>
  Imagine you're watching someone paint a wall. It's been blue for the last 20 brush
  strokes. What colour do you <em>predict</em> the next stroke will be?
</p>

<p>
  <strong>Blue</strong>, obviously. And you'd almost always be right!
</p>

<p>
  So instead of recording every brush stroke, you could record just the <em>surprises</em>
  — the moments when the colour changes:
</p>

<pre style={pre}>{`Original:     blue blue blue blue blue blue RED blue blue blue
Normal:       B    B    B    B    B    B    R   B    B    B     (10 values)
Prediction:   B    same same same same same R   same same same
Encoded:      B    ✓    ✓    ✓    ✓    ✓    R   ✓    ✓    ✓`}</pre>

<p>
  "Same as before" (✓) is an incredibly common event, so we can represent it with just
  <strong>1 bit</strong> — a single zero or one. The full colour value (which might be
  2, 4, or 8 bits) only needs to be stored when the prediction is <em>wrong</em>.
</p>

<div style={note}>
  <strong>Key insight:</strong> We're not storing what the pixels ARE — we're storing
  how they DIFFER from what we expected. If our predictions are usually right, most
  of the data is just "yep, got it" (1 bit) instead of "here's the actual value"
  (many bits).
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Context: Making Better Predictions</h2>

<p>
  The simplest prediction is "same as the last pixel." But we can be smarter. What if
  we noticed that in this particular image:
</p>

<ul style={{ paddingLeft: 20 }}>
  <li>After colour 0 (black), the next pixel is <em>always</em> black</li>
  <li>After colour 1 (dark), it's <em>usually</em> dark, but sometimes switches to colour 3</li>
  <li>After colour 3 (light), it switches back to 1 about half the time</li>
</ul>

<p>
  This is <strong>context-based prediction</strong> — what we predict depends on the
  <em>context</em> (in this case, the current pixel's colour). By tailoring predictions
  to each colour, we can be right more often and use fewer bits.
</p>

<p>
  PP1 does exactly this. For each of the 4 colour values, it asks:
  "What colours can follow this one?" and builds a custom prediction table.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Variable-Length Codes: Spending Bits Wisely</h2>

<p>
  Not all events are equally likely. "Stay the same colour" happens much more often
  than "switch to a rare colour." So we should use <em>fewer bits</em> for common
  events and <em>more bits</em> for rare ones.
</p>

<p>
  Think of it like Morse code: the letter 'E' (super common) is just a single dot,
  while 'Q' (rare) is dash-dash-dot-dash. The same idea works for compression:
</p>

<pre style={pre}>{`Event                   Frequency    Code     Bits
────────────────────    ─────────    ─────    ────
Stay the same colour    very common  1        1 bit
Switch to follower 1    common       01       2 bits
Switch to follower 2    rare         001      3 bits
Switch to follower 3    very rare    000      3 bits`}</pre>

<p>
  This is called a <strong>variable-length code</strong> (or "prefix code"). The clever
  part: no code is a prefix of another, so the decoder always knows when one code ends
  and the next begins. It just reads bits one at a time and follows the tree.
</p>

<pre style={pre}>{`Decision tree:

  Read a bit:
  ├── 1 → "stay same" (DONE — just 1 bit!)
  └── 0 → read another bit:
       ├── 1 → "use follower 1" (DONE — 2 bits)
       └── 0 → read another bit:
            ├── 1 → "use follower 2" (DONE — 3 bits)
            └── 0 → "use follower 3" (DONE — 3 bits)`}</pre>

<div style={note}>
  This is exactly how PP1's Type 3 prediction works. The most common outcome ("stay
  the same") costs just 1 bit. The primary follower costs 2 bits. Rare followers
  cost 3 bits. The compressor is smart about assigning which follower goes where.
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Putting It All Together</h2>

<p>A prediction-based compressor works in four stages:</p>

<h3 style={h3}>1. Analyse the Data</h3>
<p>
  Look at the image and count: "How often does colour A follow colour B?"
  Build a transition table — a map of what follows what.
</p>

<pre style={pre}>{`Example: "After colour 1, what happens?"
  → stays 1:    47 times   (most common)
  → becomes 3:  8 times    (sometimes)
  → becomes 0:  1 time     (rare)
  → becomes 2:  0 times    (never happens)`}</pre>

<h3 style={h3}>2. Build the Prediction Table</h3>
<p>
  For each colour, decide how many followers it needs and assign them to
  the cheapest code slots. Colour 1 above needs only 2 followers (3 and 0),
  so it gets Type 2 — each pixel costs 1-2 bits.
</p>

<h3 style={h3}>3. Encode</h3>
<p>
  Walk through the pixels left-to-right. For each one, look up the prediction table
  and write the bit code: "1" for same, "01" for follower 1, etc.
</p>

<pre style={pre}>{`Pixels:  1  1  1  3  3  1  1  1
Encode:  [seed=1]
         1→1: "1"           (stay same, 1 bit)
         1→1: "1"           (stay same, 1 bit)
         1→3: "01"          (follower 1, 2 bits)
         3→3: "1"           (stay same, 1 bit)
         3→1: "01"          (follower 1, 2 bits)
         1→1: "1"           (stay same, 1 bit)
         1→1: "1"           (stay same, 1 bit)

Total: 2 (seed) + 1+1+2+1+2+1+1 = 11 bits for 8 pixels
Raw: 8 × 2 = 16 bits
Saved: 31%!`}</pre>

<h3 style={h3}>4. Decode</h3>
<p>
  The decoder reads the prediction table, then walks through the bit stream,
  following the decision tree for each pixel. It always knows exactly which branch
  to take — no ambiguity, no backtracking.
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Why Pixels? Why Not Whole Images?</h2>

<p>
  You might wonder: "Why predict individual pixels? Why not compress the whole image
  at once?" Good question! There are trade-offs:
</p>

<table style={tbl}>
  <thead>
    <tr><th style={th}>Approach</th><th style={th}>Good at</th><th style={th}>Bad at</th><th style={th}>Cost</th></tr>
  </thead>
  <tbody>
    <tr>
      <td style={td}>Pixel prediction</td>
      <td style={{...td,...grn}}>Fast, tiny code, low RAM</td>
      <td style={td}>Not the best ratio</td>
      <td style={td}>~200 bytes of code</td>
    </tr>
    <tr>
      <td style={td}>Dictionary (LZ77)</td>
      <td style={{...td,...grn}}>Great ratios on repeated patterns</td>
      <td style={td}>Needs RAM for window buffer</td>
      <td style={td}>~500+ bytes of code</td>
    </tr>
    <tr>
      <td style={td}>Huffman trees</td>
      <td style={{...td,...grn}}>Optimal for known symbol frequencies</td>
      <td style={td}>Needs to store the tree</td>
      <td style={td}>~400+ bytes of code</td>
    </tr>
    <tr>
      <td style={td}>Modern (DEFLATE, etc.)</td>
      <td style={{...td,...grn}}>Best ratios</td>
      <td style={td}>Way too much code and RAM</td>
      <td style={td}>Thousands of bytes</td>
    </tr>
  </tbody>
</table>

<p>
  On the NES, with only <strong>2 KB of RAM</strong> and a <strong>1.79 MHz CPU</strong>,
  pixel prediction hits the sweet spot: tiny code, almost no RAM needed, fast enough
  for loading screens, and compression ratios of 30-70%. The whole decompressor fits in
  about 280 bytes — less space than this paragraph takes up as text!
</p>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Prediction in the Real World</h2>

<p>
  Pixel prediction isn't just an NES trick — it's used everywhere in modern computing:
</p>

<ul style={{ paddingLeft: 20 }}>
  <li>
    <strong>PNG images</strong> use prediction filters (Sub, Up, Average, Paeth) that
    predict each pixel from its neighbours, then compress the differences. The idea is
    the same as PP1, just more sophisticated.
  </li>
  <li>
    <strong>Video codecs</strong> (H.264, H.265, AV1) predict each block of pixels
    from surrounding blocks and previous frames. Only the differences (residuals) are
    stored — that's why video files are so much smaller than storing each frame as a
    separate image.
  </li>
  <li>
    <strong>Audio codecs</strong> (FLAC, ALAC) predict each audio sample from previous
    samples. Music is very predictable (smooth waves), so the differences are tiny and
    compress well.
  </li>
  <li>
    <strong>Text prediction</strong> (what your phone keyboard does!) is the same idea:
    predict the next word, only encode the surprise when you type something unexpected.
    Large language models are essentially very powerful predictors.
  </li>
</ul>

<div style={note}>
  <strong>The universal principle:</strong> Prediction + encoding surprises is one of
  the most powerful ideas in all of information theory. Claude Shannon proved in 1948
  that the best possible compression is directly related to how predictable the data
  is. PP1 on the NES and a modern video codec on your phone are both implementations
  of this same fundamental insight — just at very different scales.
</div>

{/* ═══════════════════════════════════════════════════════════ */}
<h2 style={h2}>Try It Yourself!</h2>

<p>
  Now that you understand the concepts, use the interactive demo to see prediction
  compression in action:
</p>

<ol style={{ paddingLeft: 20 }}>
  <li>
    <strong>Decompress mode:</strong> Watch as the decoder reads bits and predicts
    each pixel. Notice how "repeat" (1 bit) is by far the most common operation —
    that's the prediction being right!
  </li>
  <li>
    <strong>Compress mode:</strong> See how the compressor analyses the tile, counts
    transitions, assigns types, and encodes each pixel. Watch the transition matrix
    to understand <em>why</em> it picks certain types and followers.
  </li>
  <li>
    <strong>Upload your own tiles:</strong> Draw an 8×8 tile in a pixel editor,
    save it as raw CHR data, and compress it. Try different patterns — solid areas,
    stripes, checkerboards, random noise — and see how the compression ratio changes.
  </li>
</ol>

<p>
  Press <strong>?</strong> for the PP1-specific format reference with all the technical
  details — lookup tables, bit patterns, 6502 tricks, and everything else.
</p>

      </div>
    </div>
  );
};

export default LearnModal;
