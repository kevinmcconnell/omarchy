#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')

assertEqual(idle.activeSuspendTimeout(true, 3600, 0), 3600, 'idle picks battery suspend timeout on battery')
assertEqual(idle.activeSuspendTimeout(false, 3600, 0), 0, 'idle picks AC suspend timeout on AC')
assertEqual(idle.activeSuspendTimeout(true, 'nope', 0), 0, 'idle disables suspend for invalid battery timeout')
assertEqual(idle.activeSuspendTimeout(false, 3600, 1800), 1800, 'idle uses AC timeout when plugged in')

assertEqual(idle.firstIdleTimeout([150, 300, 3600]), 150, 'idle first timeout is the smallest positive stage')
assertEqual(idle.firstIdleTimeout([150, 300, 0]), 150, 'idle ignores a disabled suspend stage')
assertEqual(idle.firstIdleTimeout([0, 300, 60]), 60, 'idle first timeout ignores a zeroed stage')
assertEqual(idle.firstIdleTimeout([0, 0, 0]), 0, 'idle first timeout is zero when nothing is armed')

assertDeepEqual(idle.eventParts({ data: 'a,b,c' }, 2), ['a', 'b', 'c'], 'idle parses raw event data')
assertDeepEqual(
  idle.eventParts({ parse: function(count) { return ['parsed', count] } }, 4),
  ['parsed', 4],
  'idle prefers event parser when available'
)

assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, 'b', true),
  { windows: { a: true, b: true }, count: 2 },
  'idle adds visible screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true, b: true }, 'a', false),
  { windows: { b: true }, count: 1 },
  'idle removes closed screensaver windows'
)
assertDeepEqual(
  idle.screensaverWindowsAfter({ a: true }, '', false),
  { windows: { a: true }, count: 1 },
  'idle leaves screensaver windows unchanged without an address'
)
JS
