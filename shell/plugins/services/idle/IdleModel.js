function secondsFromConfig(value, fallback) {
  var n = Number(value)
  if (!isFinite(n) || n < 0) return fallback
  return Math.floor(n)
}

function activeSuspendTimeout(onBattery, onBatterySecs, onAcSecs) {
  return onBattery ? secondsFromConfig(onBatterySecs, 0) : secondsFromConfig(onAcSecs, 0)
}

function firstIdleTimeout(candidates) {
  var list = candidates || []
  var min = null
  for (var i = 0; i < list.length; i++) {
    var v = Number(list[i])
    if (!isFinite(v) || v <= 0) continue
    if (min === null || v < min) min = v
  }
  return min === null ? 0 : min
}

function eventParts(event, count) {
  try {
    if (event && event.parse) return event.parse(count)
  } catch (error) {
  }
  return String(event && event.data ? event.data : "").split(",")
}

function screensaverWindowsAfter(windows, address, visible) {
  var key = String(address || "")
  if (!key) {
    var current = windows || {}
    var existingCount = 0
    for (var currentKey in current) {
      if (current[currentKey]) existingCount++
    }
    return { windows: current, count: existingCount }
  }

  var next = {}
  var count = 0
  for (var existing in windows || {}) {
    if (existing !== key && windows[existing]) {
      next[existing] = true
      count++
    }
  }

  if (visible) {
    next[key] = true
    count++
  }

  return {
    windows: next,
    count: count
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    secondsFromConfig: secondsFromConfig,
    activeSuspendTimeout: activeSuspendTimeout,
    firstIdleTimeout: firstIdleTimeout,
    eventParts: eventParts,
    screensaverWindowsAfter: screensaverWindowsAfter
  }
}
