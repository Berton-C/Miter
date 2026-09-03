const fs = require('fs');
const crypto = require('crypto');
const base = require('path').resolve(__dirname, '../..');
const draft = fs.readFileSync(base + '/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md', 'utf8');
const mirror = fs.readFileSync(base + '/docs/MITER_SOUL_CONSTITUTIVE_SPEC_DRAFT.md', 'utf8');
const report = fs.readFileSync(base + '/docs/MITER_SOUL_BUILD_REASSESSMENT.md', 'utf8');
const constitution = fs.readFileSync(base + '/CONSTITUTION.md', 'utf8');
const failures = [];
const check = (ok, message) => { if (!ok) failures.push(message); };
const ids = (s, re) => [...s.matchAll(re)].map(m => m[1]);
const unique = a => new Set(a);
const sids = ids(draft, /^\*\*(S-\d+) —/gm);
const fids = ids(draft, /^### (FC-\d+) —/gm);
const tids = ids(draft, /^\| (T-\d+) \|/gm);
const dids = ids(draft, /^### (D-\d+) —/gm);
const ledgerText = draft.split('# Appendix A —')[1].split('# Appendix B —')[0];
const ledger = ledgerText.split('\n').filter(l => /^\| (?:S|FC)-\d+ \|/.test(l));
const ledgerIds = ledger.map(l => l.split('|')[1].trim());
check(draft === mirror, 'Draft copies differ');
check((draft.match(/^# Part \d+ —/gm) || []).length === 12, 'Part count');
check(sids.length === 64 && unique(sids).size === 64, 'S requirement uniqueness/count');
check(fids.length === 9 && unique(fids).size === 9, 'FC uniqueness/count');
check(tids.length === 36 && unique(tids).size === 36, 'T uniqueness/count');
check(dids.length === 13 && unique(dids).size === 13, 'Decision topics');
check(ledger.length === 73 && unique(ledgerIds).size === 73, 'Ledger count/uniqueness');
for (const row of ledger) check(row.split('|').slice(1,-1).length === 7 && row.split('|').slice(1,-1).every(x=>x.trim()), 'Malformed ledger row: ' + row);
for (const id of [...sids,...fids]) check(ledgerIds.includes(id), 'Missing ledger ID: ' + id);
const cids = unique(ids(constitution, /\b(C-\d{3})\b/g));
const mapped = ids(draft.split('# Appendix B —')[1].split('# Appendix C —')[0], /^\| (C-\d{3}) \|/gm);
check(cids.size === 81 && mapped.length === 81 && unique(mapped).size === 81, 'Constitution count');
for (const id of cids) check(mapped.includes(id), 'Missing constitutional coverage: ' + id);
const all = new Set([...sids,...fids,...tids,...dids,...cids,'R-01']);
for (const text of [draft,report]) {
  for (const id of ids(text, /\b((?:S|FC|T|D|C|R)-\d{2,4})\b/g)) check(all.has(id), 'Undefined reference: ' + id);
}
const slug = s => s.toLowerCase().replace(/[^\p{L}\p{N}_\-\s]/gu,'').replace(/ /g,'-');
const anchors = new Set(ids(draft, /^#{1,6} (.+)$/gm).map(slug));
for (const a of ids(draft, /\]\(#([^)]*)\)/g)) check(anchors.has(a), 'Missing navigation anchor: '+a);
let linkCount = 0;
for (const text of [draft,report]) {
  const links = [...text.matchAll(/\]\((<[^>]+>|(?:\\.|[^()\s]|\([^()]*\))+?)\)/g)].map(m=>m[1].replace(/^<|>$/g,''));
  for (const target of links) {
    if (!target.startsWith('/')) continue;
    const match = target.match(/^(.*?)(?::(\d+))?$/);
    const path = match[1];
    check(fs.existsSync(path), 'Missing local link: '+path);
    if (fs.existsSync(path) && match[2]) check(fs.readFileSync(path,'utf8').split('\n').length >= Number(match[2]), 'Link beyond file: '+target);
    linkCount++;
  }
}
const registry = draft.split('## C.1 Source identities and standing')[1].split('## C.2 SHA-256 fingerprints')[0];
const sourceRows = [...registry.matchAll(/^\| ([A-Z]+\d*) \| \[[^\n]*?\]\(<([^>]+)>\)/gm)];
const hashes = new Map([...draft.matchAll(/^([A-Z]+\d*)\s+([a-f0-9]{64})$/gm)].map(m=>[m[1],m[2]]));
check(sourceRows.length === 47 && hashes.size === 47, 'Source/hash count');
for (const [,id,path] of sourceRows) {
  if (!fs.existsSync(path)) { failures.push('Missing source '+id); continue; }
  const hash = crypto.createHash('sha256').update(fs.readFileSync(path)).digest('hex');
  check(hashes.get(id) === hash, 'Source fingerprint mismatch '+id);
}
check((registry.match(/^\| I[12] \|/gm)||[]).length === 2, 'Remote reference count');
for (const [name,text] of [['draft',draft],['report',report]]) {
  check((text.match(/^~~~/gm)||[]).length % 2 === 0, 'Unbalanced tilde fence '+name);
  check((text.match(/^```/gm)||[]).length % 2 === 0, 'Unbalanced code fence '+name);
}
console.log(JSON.stringify({result:failures.length?'FAIL':'PASS',parts:12,requirements:sids.length,flourishingRecords:fids.length,ledgerRows:ledger.length,testFamilies:tids.length,decisionTopics:dids.length,constitutionalClauses:cids.size,localSources:sourceRows.length,remoteReferences:2,localLinksChecked:linkCount,copiesIdentical:draft===mirror,failures},null,2));
process.exitCode = failures.length ? 1 : 0;
