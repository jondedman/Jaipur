# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "tailwindcss" # @3.4.1
# pin "#node.js" # @4.22.3
pin "@alloc/quick-lru", to: "@alloc--quick-lru.js" # @5.2.0
pin "@jridgewell/gen-mapping", to: "@jridgewell--gen-mapping.js" # @0.3.3
pin "@jridgewell/resolve-uri", to: "@jridgewell--resolve-uri.js" # @3.1.1
pin "@jridgewell/set-array", to: "@jridgewell--set-array.js" # @1.1.2
pin "@jridgewell/sourcemap-codec", to: "@jridgewell--sourcemap-codec.js" # @1.4.15
pin "@jridgewell/trace-mapping", to: "@jridgewell--trace-mapping.js" # @0.3.22
pin "@nodelib/fs.scandir", to: "@nodelib--fs.scandir.js" # @2.1.5
pin "@nodelib/fs.stat", to: "@nodelib--fs.stat.js" # @2.0.5
pin "@nodelib/fs.walk", to: "@nodelib--fs.walk.js" # @1.2.8
pin "@tailwindcss/line-clamp", to: "@tailwindcss--line-clamp.js" # @0.4.4
pin "@tailwindcss/oxide", to: "@tailwindcss--oxide.js" # @2.0.1
pin "assert" # @2.0.1
pin "braces" # @3.0.2
pin "browserslist" # @4.22.3
pin "buffer" # @2.0.1
pin "camelcase-css" # @2.0.1
pin "caniuse-lite/dist/unpacker/agents", to: "caniuse-lite--dist--unpacker--agents.js" # @1.0.30001585
pin "child_process" # @2.0.1
pin "crypto" # @2.0.1
pin "cssesc" # @3.0.0
pin "detect-libc" # @1.0.3
pin "didyoumean" # @1.2.2
pin "dlv" # @1.1.3
pin "electron-to-chromium/versions", to: "electron-to-chromium--versions.js" # @1.4.665
pin "events" # @2.0.1
pin "fast-glob" # @3.3.2
pin "fastq" # @1.17.1
pin "fill-range" # @7.0.1
pin "fs" # @2.0.1
pin "glob-parent" # @6.0.2
pin "is-extglob" # @2.1.1
pin "is-glob" # @4.0.3
pin "is-number" # @7.0.0
pin "jiti" # @1.21.0
pin "lightningcss" # @1.23.0
pin "lines-and-columns" # @1.2.4
pin "merge2" # @1.4.1
pin "micromatch" # @4.0.5
pin "module" # @2.0.1
pin "nanoid/non-secure", to: "nanoid--non-secure.js" # @3.3.7
pin "node-releases/data/processed/envs.json", to: "node-releases--data--processed--envs.json.js" # @2.0.14
pin "node-releases/data/release-schedule/release-schedule.json", to: "node-releases--data--release-schedule--release-schedule.json.js" # @2.0.14
pin "normalize-path" # @3.0.0
pin "object-hash" # @3.0.0
pin "os" # @2.0.1
pin "path" # @2.0.1
pin "perf_hooks" # @2.0.1
pin "picocolors" # @1.0.0
pin "picomatch" # @2.3.1
pin "picomatch/lib/utils", to: "picomatch--lib--utils.js" # @2.3.1
pin "postcss" # @8.4.35
pin "postcss-js" # @4.0.1
pin "postcss-nested" # @6.0.1
pin "postcss-selector-parser" # @6.0.15
pin "postcss-selector-parser/dist/util/unesc", to: "postcss-selector-parser--dist--util--unesc.js" # @6.0.15
pin "process" # @2.0.1
pin "queue-microtask" # @1.2.3
pin "reusify" # @1.0.4
pin "run-parallel" # @1.2.0
pin "source-map-js" # @1.0.2
pin "stream" # @2.0.1
pin "sucrase" # @3.35.0
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js" # @3.4.1
pin "to-regex-range" # @5.0.1
pin "ts-interface-checker" # @0.1.13
pin "tty" # @2.0.1
pin "url" # @2.0.1
pin "util" # @2.0.1
pin "util-deprecate" # @1.0.2
pin "v8" # @2.0.1
pin "vm" # @2.0.1
