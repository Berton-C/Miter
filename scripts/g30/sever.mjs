// Builder-side causal mutants for G30 only.  These are never candidate repairs.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {hash, save} from '../g22_v2/common.mjs';

const identityClause = `authorized(Config, Frame, SID, TID, CID, UID) :-
    is_dict(Config),
    is_dict(Frame),
    get_dict(server_id, Frame, SID),
    get_dict(team_id, Frame, TID),
    get_dict(channel_id, Frame, CID),
    get_dict(user_id, Frame, UID),
    get_dict(server_id, Config, SID),
    get_dict(team_id, Config, TID),
    get_dict(channel_id, Config, CID),
    get_dict(user_id, Config, UID).`;

const identitySevered = `authorized(Config, Frame, SID, TID, CID, UID) :-
    is_dict(Config),
    is_dict(Frame),
    get_dict(server_id, Frame, SID),
    get_dict(team_id, Frame, TID),
    get_dict(channel_id, Frame, CID),
    get_dict(user_id, Frame, UID).`;

const effectClause = `effect_frame(Config, State0, Effect, State, Outcome) :-
    get_dict(schema, Effect, 'miter-surface-effect-v1'),
    get_dict(id, Effect, ID),
    get_dict(idempotency_key, Effect, IK),
    get_dict(channel_id, Effect, CID),
    get_dict(message, Effect, M), !,
    (   get_dict(channel_id, Config, ConfigCID),
        CID == ConfigCID
    ->  get_dict(effects, State0, Effects),
        (   memberchk(ID-IK, Effects)
        ->  State = State0,
            Outcome = _{status:suppressed, reason:duplicate_effect}
        ;   State = State0.put(effects, [ID-IK|Effects]),
            Outcome = _{status:accepted,
                        descriptor:_{method:post,
                                     path:'/api/v4/posts',
                                     body:_{channel_id:CID, message:M},
                                     idempotency_key:IK}}
        )
    ;   State = State0,
        Outcome = _{status:rejected, reason:unauthorized_channel}
    ).`;

const idempotencySevered = `effect_frame(Config, State0, Effect, State, Outcome) :-
    get_dict(schema, Effect, 'miter-surface-effect-v1'),
    get_dict(id, Effect, ID),
    get_dict(idempotency_key, Effect, IK),
    get_dict(channel_id, Effect, CID),
    get_dict(message, Effect, M), !,
    (   get_dict(channel_id, Config, ConfigCID),
        CID == ConfigCID
    ->  get_dict(effects, State0, Effects),
        State = State0.put(effects, [ID-IK|Effects]),
        Outcome = _{status:accepted,
                    descriptor:_{method:post,
                                 path:'/api/v4/posts',
                                 body:_{channel_id:CID, message:M},
                                 idempotency_key:IK}}
    ;   State = State0,
        Outcome = _{status:rejected, reason:unauthorized_channel}
    ).`;

function replaceOnce(source, before, after, label) {
  const first = source.indexOf(before);
  assert.notEqual(first, -1, `${label} source clause missing`);
  assert.equal(source.indexOf(before, first + 1), -1,
    `${label} source clause is not unique`);
  return source.slice(0, first) + after + source.slice(first + before.length);
}

export function buildSevered(candidatePath, outputRoot, provenancePath) {
  const canonical = fs.readFileSync(candidatePath, 'utf8');
  const identity = replaceOnce(canonical, identityClause, identitySevered,
    'identity allowlist');
  const idempotency = replaceOnce(canonical, effectClause, idempotencySevered,
    'idempotency suppression');
  const rows = [
    ['identity', identity, 'identity-allowlist-clause-removed'],
    ['idempotency', idempotency, 'duplicate-effect-suppression-removed']
  ];
  const variants = [];
  for (const [name, source, severance] of rows) {
    const file = path.join(outputRoot, name, 'extension',
      'mattermost_bridge.pl');
    fs.mkdirSync(path.dirname(file), {recursive:true});
    fs.writeFileSync(file, source);
    variants.push({name, path:file, sha256:hash(Buffer.from(source)),
      severance});
  }
  save(provenancePath, {
    schema:'miter-g30-severance-v1',
    canonical_path:candidatePath,
    canonical_sha256:hash(Buffer.from(canonical)),
    variants,
    standing:'builder-authored-negative-controls-only-never-candidates'
  });
  return variants;
}
