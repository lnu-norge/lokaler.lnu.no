// From https://github.com/rails/jsbundling-rails/issues/8#issuecomment-1403699565
// Feel free to adapt as we need

import path from 'path'
import esbuild from 'esbuild'
import railsPlugin from 'esbuild-rails'
import dotenv from 'dotenv'
dotenv.config()

// Add ENV variables needed for JS here (if you don't inject them from ruby instead)
const define = {}

if (process.env.POSTHOG_API_KEY) {
    define["window.POSTHOG_API_KEY"] = JSON.stringify(process.env.POSTHOG_API_KEY)
}


if (process.env.RAILS_ENV !== "production" || process.env.RAILS_ENV !== "test") {
    // If nothing else set, we are probably in dev
    define["window.ESBUILD_RAILS_ENV"] = JSON.stringify("development")
} else {
    define["window.ESBUILD_RAILS_ENV"] = JSON.stringify(process.env.RAILS_ENV)
}

esbuild.context({
    // Always bundle
    bundle:  true,
    // Path to application.js folder
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    // Application.js file, used by Rails to bundle all JS Rails code
    entryPoints: ["application.js"],
    // Compresses bundle
    // More information: https://esbuild.github.io/api/#minify
    minify: process.argv.includes("--minify"),
    // Adds mapping information so web browser console can map bundle errors to the corresponding
    // code line and column in the real code
    // More information: https://esbuild.github.io/api/#sourcemap
    sourcemap: process.argv.includes("--sourcemap"),
    // Destination of JS bundle, points to the Rails JS Asset folder
    outdir: path.join(process.cwd(), "app/assets/builds"),
    // Remove unused JS methods
    treeShaking: true,
    plugins: [
        // Plugin to easily import Rails JS files, such as Stimulus controllers and channels
        // https://github.com/excid3/esbuild-rails
        railsPlugin()
    ],
    // Variables passed to scripts, defined up above
    define
}).then(context => {
    if (process.argv.includes("--watch")) {
        // Enable watch mode
        context.watch()
    } else {
        // Build once and exit if not in watch mode
        context.rebuild().then(result => {
            context.dispose()
        })
    }
}).catch(() => process.exit(1))
