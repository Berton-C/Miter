#!/usr/bin/env python3
import sys
sys.path.insert(0, '/tmp')
from vad_chromadb_bridge import lookup_word, discretize_vad, get_client

client = get_client()
coll = client.get_collection('nrc_vad_full')

def vad_lookup_grounded(word_str):
    r = lookup_word(word_str, coll)
    if r is None:
        return '(vad-result %s UNKNOWN)' % word_str
    v, a, d = r
    vl, al, dl = discretize_vad(v, a, d)
    return '(vad-result %s (VADCell %s %s %s) (VADRaw %.3f %.3f %.3f))' % (word_str, vl, al, dl, v, a, d)

if __name__ == '__main__':
    for w in sys.argv[1:]:
        print(vad_lookup_grounded(w))
