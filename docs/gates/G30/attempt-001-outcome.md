# G30 attempt 001 — mock evidence serializer failed before candidate trial

The exact `mattermost-r9` candidate passed native preflight and remained unchanged. During the first canonical mock phase, the builder-authored Prolog mock attempted to serialize an absent event with `@(null)`. SWI-Prolog's dict JSON writer rejected that term as `type_error(json_term,@null)`. PeTTa/MeTTa received the typed mock failure and returned `g30-mock-unqualified`; no behavioral G30 claim was admitted.

The same serializer failure occurred before canonical or severed behavior could be observed. Partial `.tmp` files are retained as raw failure evidence. No model, credential, network, live service, activation, or promotion participated.

R1 may change only the builder mock's null sentinel to the JSON-supported atom and update the attempt driver to open the R1 plan. The candidate bytes, mock scenarios, native acceptance relations, and severed transformations remain unchanged. A fresh attempt identity is required.
