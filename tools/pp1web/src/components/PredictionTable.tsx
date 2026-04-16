import type { Header } from '../pp1/types';

interface PredictionTableProps {
  header: Header;
  highlightX: number;
}

const TYPE_BADGES = ['type-0', 'type-1', 'type-2', 'type-3'];

const PredictionTable: React.FC<PredictionTableProps> = ({ header, highlightX }) => {
  return (
    <>
      <table className="prediction-table">
        <thead>
          <tr>
            <th>Pixel</th>
            <th>Type</th>
            <th>fol1</th>
            <th>fol2</th>
            <th>fol3</th>
          </tr>
        </thead>
        <tbody>
          {[0, 1, 2, 3].map(x => {
            const t = header.types[x];
            return (
              <tr key={x} className={x === highlightX ? 'highlight-col' : ''}>
                <td>{x}</td>
                <td><span className={TYPE_BADGES[t]}>{t}</span></td>
                <td>{t >= 1 ? header.fol1[x] : '-'}</td>
                <td>{t >= 2 ? header.fol2[x] : '-'}</td>
                <td>{t >= 3 ? header.fol3[x] : '-'}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
      <div className="lookup-ref">
        <b>T1 tree:</b> bit 1→FC1[x] | 01→FC3[x] | 00→FC2[x]<br/>
        <b>FC1:</b> [1,0,0,0] <b>FC2:</b> [2,2,1,1] <b>FC3:</b> [3,3,3,2]<br/>
        <b>Predict:</b> type0: self | type1: 1→self, 0→fol1<br/>
        type2: 1→self, 00→fol1, 01→fol2<br/>
        type3: 1→self, 01→fol1, 001→fol3, 000→fol2
      </div>
    </>
  );
};

export default PredictionTable;
