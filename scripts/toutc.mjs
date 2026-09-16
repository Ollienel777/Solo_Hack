// Convert a wall-clock time in an IANA timezone to UTC.
//   node scripts/toutc.mjs 2026-10-03 18:00 America/Toronto   ->  2026-10-03T22:00:00Z
// Exits non-zero on a malformed date or an unknown zone. Git Bash's `date` has
// no zoneinfo on Windows and silently treats every zone as UTC, so the build
// loop's clock uses this instead.
const [day, time, zone] = process.argv.slice(2);
if (!/^\d{4}-\d{2}-\d{2}$/.test(day ?? '') || !/^\d{2}:\d{2}$/.test(time ?? '') || !zone) {
  console.error('usage: node scripts/toutc.mjs YYYY-MM-DD HH:MM Area/City');
  process.exit(2);
}
// Only IANA Area/City names (or UTC). Abbreviations like EST are accepted by
// Intl but ignore daylight saving, which is exactly the error to avoid.
if (zone !== 'UTC' && !/^[A-Za-z_]+\/[A-Za-z0-9_+\-\/]+$/.test(zone)) {
  console.error(`use an IANA zone like America/Toronto, not: ${zone}`);
  process.exit(2);
}
let fmt;
try {
  fmt = new Intl.DateTimeFormat('en-US', {
    timeZone: zone, hourCycle: 'h23', year: 'numeric', month: '2-digit',
    day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit',
  });
} catch {
  console.error(`unknown timezone: ${zone}`);
  process.exit(1);
}
// Offset of `zone` from UTC at instant `ms`, in milliseconds.
const offset = (ms) => {
  const p = Object.fromEntries(fmt.formatToParts(ms).map((x) => [x.type, x.value]));
  return Date.UTC(p.year, p.month - 1, p.day, p.hour, p.minute, p.second) - ms;
};
const wall = Date.parse(`${day}T${time}:00Z`);
// Date.parse rolls 2026-02-30 over to March; require the value to round-trip.
if (Number.isNaN(wall) || new Date(wall).toISOString().slice(0, 16) !== `${day}T${time}`) {
  console.error(`invalid date: ${day} ${time}`);
  process.exit(2);
}
// Two passes settle the offset across a DST boundary.
let utc = wall - offset(wall);
utc = wall - offset(utc);
console.log(new Date(utc).toISOString().replace('.000Z', 'Z'));
