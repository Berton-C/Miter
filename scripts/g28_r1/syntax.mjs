import fs from 'node:fs';import {parse} from '../sc04/fixtures.mjs';
for(const f of ['src/development_continuation_v1.metta','src/executable_development_v2.metta']){
 const forms=parse('('+fs.readFileSync(f,'utf8').split('\n').filter(l=>!l.startsWith(';')).join('\n')+')');
 const visit=x=>{if(Array.isArray(x)){if(['if','let'].includes(x[0])&&x.length!==4)throw Error(f+JSON.stringify(x));if(x[0]==='let*'&&x.length!==3)throw Error(f+JSON.stringify(x));x.forEach(visit)}};
 visit(forms);console.log(f+' balanced; binding/branch shapes checked');
}
