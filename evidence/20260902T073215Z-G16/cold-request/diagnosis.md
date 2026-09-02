The first cold-request explanation was a hypothesis, not a proven cause.
The warm retry also failed. Local server timing for that retry reports
1024 generated tokens, all 1024 classified as reasoning tokens, with no
final answer; generation took about 135 seconds. The tiny provider probe
also exhausted its 32-token budget in reasoning without a final answer.
G05's successful decoding explicitly used reasoning_effort: none; the new
G16 request had omitted that setting. Restore the previously proven setting.
The SWI time-limit signal was delayed during HTTP I/O; a process-level
deadline is needed instead of claiming an exact 120-second hard limit.
