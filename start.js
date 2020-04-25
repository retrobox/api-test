const childProcess = require('child_process')
const dotEnv = require('dotenv')
const chalk = require("chalk")

console.log(chalk.gray('Test loading...'))

dotEnv.config()

let config = {
    baseUrl: process.env.API_ENDPOINT,
    masterKey: process.env.API_MASTER_KEY
}

if (config.baseUrl.substr(config.baseUrl.length - 1) !== '/')
    config.baseUrl += "/"

let cmd = ['-cp', 'karate.jar:.', `-Dkarate.env=${JSON.stringify(config)}`, 'com.intuit.karate.Main', 'test']

let karate = childProcess.spawn('java', cmd)

karate.stdout.pipe(process.stdout)
karate.stderr.pipe(process.stderr)

karate.on('close', code => {
    if (code == 0)
        console.log(chalk.bold(chalk.green("Test suite succeeded")))
    else 
        console.log(chalk.bold(chalk.red("Test suite failed")))
    console.log(chalk.gray('Karate process exited with code ' + code))
    process.exit()
})
