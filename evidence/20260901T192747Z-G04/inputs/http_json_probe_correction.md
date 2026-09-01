# Native SWI JSON POST probe correction

The first direct transport probe returned `prepared-request-unavailable` before any request reached LM Studio. An uncaught rerun showed that `http_header:http_post_data/3` had no rule for `json(Dict)`: `library(http/http_client)` was present, but the SWI JSON POST-data handler was not loaded.

The membrane was corrected to import `library(http/http_json)`. Error classification was also narrowed: only an actually absent prepared-request file returns `prepared-request-unavailable`; later transport exceptions return `inference-transport-error` unless they are a socket or timeout condition.

No provider response or semantic-result artifact was created by the failed probe.

A second diagnostic reached Qwen successfully but then exposed a separate portability issue in the raw-body writer: this SWI build did not provide `write_string/2`. The write failed before the atomic rename, so the successful provider body was discarded and no raw or semantic-result artifact appeared. The writer was changed to `format(Stream, '~s', [Text])`, which preserves the response string without interpreting it.
