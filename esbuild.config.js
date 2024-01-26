// From https://github.com/rails/jsbundling-rails/issues/8#issuecomment-1403699565
// Feel free to adapt as we need

const path = require('path')
require('dotenv').config()

console.dir(process.argv)
console.dir(process.env)
require("esbuild").context({
    entryPoints: ["application.js"],
    bundle:  process.argv.includes("--bundle"),
    sourcemap: process.argv.includes("--sourcemap"),
    outdir: path.join(process.cwd(), "app/assets/builds"),
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    plugins: [],
    define: {
      // Put env variables needed for JS here. They are not included by default by esbuild.
      "process.env.POSTHOG_API_KEY": JSON.stringify(process.env.POSTHOG_API_KEY)
    },
    minify: process.argv.includes("--minify")
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
