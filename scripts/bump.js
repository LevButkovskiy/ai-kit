#!/usr/bin/env node
import {readdirSync, readFileSync, writeFileSync} from "node:fs";

const kind = process.argv[2];
if (!["major", "minor", "patch"].includes(kind)) {
  console.error("usage: npm run bump -- <major|minor|patch>");
  process.exit(1);
}

const files = ["package.json", ...globPlugins()];
const [maj, min, pat] = readVersion(files[0]).split(".").map(Number);
const next =
  kind === "major" ? `${maj + 1}.0.0`
  : kind === "minor" ? `${maj}.${min + 1}.0`
  : `${maj}.${min}.${pat + 1}`;

for (const f of files) {
  const raw = readFileSync(f, "utf8");
  writeFileSync(f, raw.replace(/"version":\s*"[^"]+"/, `"version": "${next}"`));
  console.log(`${f} → ${next}`);
}

function readVersion(f) {
  return JSON.parse(readFileSync(f, "utf8")).version;
}
function globPlugins() {
  return readdirSync("plugins", { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => `plugins/${d.name}/.claude-plugin/plugin.json`);
}