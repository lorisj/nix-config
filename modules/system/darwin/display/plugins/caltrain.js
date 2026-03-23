#!@node@

const http = require("http");
const zlib = require("zlib");
const fs = require("fs");

const STOP_CODE = "70022";
const CACHE_PATH = "/tmp/caltrain-swiftbar-cache.json";
const CACHE_MAX_AGE_MS = 2 * 60 * 1000;

function getToken() {
  if (process.env.CALTRAIN_TOKEN) return process.env.CALTRAIN_TOKEN;
  try {
    const env = fs.readFileSync("/etc/environment", "utf-8");
    const match = env.match(/CALTRAIN_TOKEN=(.*)/);
    if (match) return match[1].trim();
  } catch { }
  return null;
}

const API_KEY = getToken();
const API_URL = `http://api.511.org/transit/StopMonitoring?api_key=${API_KEY}&agency=CT&stopCode=${STOP_CODE}&format=json`;

function fetch511() {
  return new Promise((resolve, reject) => {
    http
      .get(API_URL, { headers: { "Accept-Encoding": "gzip,deflate" } }, (res) => {
        const stream =
          res.headers["content-encoding"] === "gzip"
            ? res.pipe(zlib.createGunzip())
            : res;
        const chunks = [];
        stream.on("data", (c) => chunks.push(c));
        stream.on("end", () => {
          let raw = Buffer.concat(chunks).toString("utf-8");
          if (raw.charCodeAt(0) === 0xfeff) raw = raw.slice(1);
          resolve(JSON.parse(raw));
        });
        stream.on("error", reject);
      })
      .on("error", reject);
  });
}

function readCache() {
  try {
    const raw = fs.readFileSync(CACHE_PATH, "utf-8");
    const cache = JSON.parse(raw);
    if (Date.now() - cache.ts < CACHE_MAX_AGE_MS) return cache.data;
  } catch { }
  return null;
}

function writeCache(data) {
  fs.writeFileSync(CACHE_PATH, JSON.stringify({ ts: Date.now(), data }));
}

const SVC = {
  Express: { dot: "🔴", short: "Exp" },
  Limited: { dot: "🔵", short: "Ltd" },
  "Limited Weekday": { dot: "🔵", short: "Ltd" },
  "Local Weekday": { dot: "⚪", short: "Lcl" },
  "Local Weekend": { dot: "⚪", short: "Lcl" },
  Local: { dot: "⚪", short: "Lcl" },
};

function svcInfo(line) {
  return SVC[line] || { dot: "⚪", short: line };
}

function relativeTime(iso) {
  const diff = Math.floor((new Date(iso) - Date.now()) / 60000);
  if (diff <= 0) return "now";
  if (diff === 1) return "1m";
  return `${diff}m`;
}

function fmtClock(iso) {
  return new Date(iso).toLocaleTimeString("en-US", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone: "America/Los_Angeles",
  });
}

function delayMins(aimed, expected) {
  if (!aimed || !expected) return 0;
  const diff = (new Date(expected) - new Date(aimed)) / 60000;
  return Math.max(0, Math.floor(diff));
}

async function main() {
  if (!API_KEY) {
    console.log("🚂 No Token");
    return;
  }

  let data = readCache();
  if (!data) {
    try {
      data = await fetch511();
      writeCache(data);
    } catch {
      console.log("🚂 Error");
      return;
    }
  }

  const visits =
    data?.ServiceDelivery?.StopMonitoringDelivery?.MonitoredStopVisit || [];

  if (!visits.length) {
    console.log("🚂 No trains");
    return;
  }

  const now = Date.now();
  const trains = visits
    .map((v) => {
      const j = v.MonitoredVehicleJourney;
      const c = j.MonitoredCall;
      return {
        train: j.FramedVehicleJourneyRef?.DatedVehicleJourneyRef,
        line: j.LineRef,
        aimed: c.AimedDepartureTime,
        expected: c.ExpectedDepartureTime,
      };
    })
    .filter((t) => new Date(t.expected || t.aimed) >= now)
    .sort(
      (a, b) =>
        new Date(a.expected || a.aimed) - new Date(b.expected || b.aimed),
    );

  if (!trains.length) {
    console.log("🚂 No trains");
    return;
  }

  const rows = trains.map((t) => {
    const depTime = t.expected || t.aimed;
    const { dot, short } = svcInfo(t.line);
    const rel = relativeTime(depTime);
    const clock = fmtClock(depTime);
    const delay = delayMins(t.aimed, t.expected);
    const late = delay > 0 ? ` +${delay}m late` : "";
    return { dot, short, rel, clock, train: t.train, delay, late };
  });

  const fmtHeader = (r) => {
    const late = r.delay > 0 ? ` (+${r.delay}m late)` : "";
    return `${r.dot} ${r.rel}${late}`;
  };

  let header = fmtHeader(rows[0]);
  if (rows[1]) header += `  ${fmtHeader(rows[1])}`;
  console.log(header);
  console.log("---");
  rows.forEach((r) => {
    console.log(`${r.dot} ${r.rel} (${r.clock}) #${r.train} ${r.short}${r.late}`);
  });
  console.log("---");
  console.log("22nd St Southbound | size=10 | color=gray");
  console.log("Refresh | refresh=true");
}

main();
