#!/usr/bin/env node
/**
 * food — release helper for FoodRescue-Sync
 *
 * Usage:
 *   food run                  Build web app, deploy Firebase Hosting, move v0.1.0 tag
 *   food run --skip-build     Skip the Flutter build (reuses build/web)
 *   food run --skip-deploy    Build but don't deploy to Firebase
 *   food run --skip-release   Don't touch the git tag / GitHub release
 *
 * Prerequisites:
 *   - `flutter` on PATH (unless --skip-build)
 *   - `firebase` CLI installed and logged in (`firebase login`) (unless --skip-deploy)
 *   - Push access to origin (for the tag move)
 */

const { execFileSync } = require("child_process");
const path = require("path");
const fs = require("fs");

const ROOT = path.resolve(__dirname, "..");
const RELEASE_TAG = "v0.1.0";

const args = new Set(process.argv.slice(2));
const SKIP_BUILD = args.has("--skip-build");
const SKIP_DEPLOY = args.has("--skip-deploy");
const SKIP_RELEASE = args.has("--skip-release");

function run(cmd, cmdArgs, opts = {}) {
  console.log(`\n> ${cmd} ${cmdArgs.join(" ")}`);
  execFileSync(cmd, cmdArgs, {
    cwd: ROOT,
    stdio: "inherit",
    shell: process.platform === "win32",
    ...opts,
  });
}

function step(msg) {
  console.log(`\n=== ${msg} ===`);
}

async function main() {
  if (process.argv.slice(2)[0] !== "run") {
    console.error('Usage: food run [--skip-build] [--skip-deploy] [--skip-release]');
    process.exit(1);
  }

  const start = Date.now();

  // 1. Build the Flutter web app
  if (!SKIP_BUILD) {
    step("Building Flutter web app");
    run("flutter", ["build", "web", "--release"]);
  } else {
    step("Skipping Flutter build (--skip-build)");
  }

  if (!fs.existsSync(path.join(ROOT, "build", "web", "index.html"))) {
    console.error("\n✗ build/web/index.html not found. Run a build first (drop --skip-build).");
    process.exit(1);
  }

  // 2. Deploy to Firebase Hosting
  if (!SKIP_DEPLOY) {
    step("Deploying to Firebase Hosting");
    run("firebase", ["deploy", "--only", "hosting", "--project", "foodrescue-sync"]);
  } else {
    step("Skipping Firebase deploy (--skip-deploy)");
  }

  // 3. Move the v0.1.0 tag to the current commit and push it,
  //    which moves the existing GitHub release under the new push.
  if (!SKIP_RELEASE) {
    step(`Moving tag ${RELEASE_TAG} to HEAD and pushing`);

    const head = execFileSync("git", ["rev-parse", "HEAD"], { cwd: ROOT, encoding: "utf8" }).trim();
    const tagSha = execFileSync("git", ["rev-parse", RELEASE_TAG], { cwd: ROOT, encoding: "utf8" }).trim();

    if (tagSha === head) {
      console.log(`Tag ${RELEASE_TAG} already points at HEAD (${head.slice(0, 7)}). Nothing to do.`);
    } else {
      run("git", ["tag", "-f", RELEASE_TAG, head]);
      // Force-push the tag. This re-points the GitHub release v0.1.0 to the new commit.
      run("git", ["push", "origin", `refs/tags/${RELEASE_TAG}`, "--force"]);
      console.log(`Release ${RELEASE_TAG} now points at ${head.slice(0, 7)}.`);
    }
  } else {
    step("Skipping release tag update (--skip-release)");
  }

  const secs = ((Date.now() - start) / 1000).toFixed(1);
  console.log(`\n✓ Done in ${secs}s`);
}

main().catch((err) => {
  console.error(`\n✗ ${err.message}`);
  process.exit(err.status || 1);
});
