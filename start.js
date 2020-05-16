const childProcess = require('child_process')
const dotEnv = require('dotenv')
const chalk = require("chalk")
const readline = require('readline')
const url = require('url')
const os = require('os')
const net = require('net')

dotEnv.config()

let config = {
    baseUrl: process.env.API_ENDPOINT,
    stailbaseUrl: process.env.STAIL_EU_API,
    masterKey: process.env.API_MASTER_KEY,
    loginUserID: process.env.LOGIN_USER_ID,
    loginPassword: process.env.LOGIN_PASSWORD,
    chromePath: process.env.CHROME_PATH,
    paypalPassword: process.env.PAYPAL_LOGIN,
    paypalLogin: process.env.PAYPAL_PASSWORD,
    mailchimpKey: process.env.MAILCHIMP_API_KEY
}

if (config.baseUrl.substr(config.baseUrl.length - 1) !== '/')
    config.baseUrl += "/"

const client = new net.Socket();
const parsedUrl = url.parse(config.baseUrl)

const waitUntilServerStarted = () => {
    return new Promise(resolve => {
        connectionConfig = {
            host: parsedUrl.hostname,
            port: parseInt(parsedUrl.port === null ? parsedUrl.protocol === 'https:' ? 443 : 80 : parsedUrl.port),
        }
        client.removeAllListeners()
        client.connect(connectionConfig, () => {
            client.end()
            console.log('ok')
            resolve()
        })
        client.on('error', () => {
            setTimeout(() => {
                console.log('retry')
                waitUntilServerStarted().then(resolve)
            }, 500)
        })
    })
}

(async () => {
    await waitUntilServerStarted()
    console.log('> Got connexion')
    let args = process.argv.slice(2)
    if (process.env.CLI_ARGS !== undefined) {
        args = args.concat(process.env.CLI_ARGS.split(';'))
    }
    let isDebug = args.filter(a => a === '-D').length === 1
    if (process.env.DEBUG === '1' || process.env.DEBUG === 'true')
        isDebug = true
    if (isDebug)
        args = args.filter(a => a !== '-D')
    let path = __dirname
    if (os.type() === 'Windows_NT')
        path = path + '\\karate.jar'
    else
        path += '/karate.jar:.'
    if (process.env.KARATE_PATH !== undefined)
        path = process.env.KARATE_PATH
    let envPassing = ""
    for (var key in config)
        envPassing += key + "%=" + config[key] + "%;"
    if (envPassing.slice(-2) == "%;")
        envPassing = envPassing.substr(0, envPassing.length - 2)
    let cmd = [
        '-cp',
        path,
        `-Dkarate.env=${envPassing}`,
        'com.intuit.karate.Main',
        '-T', '1',
        args.length > 0 ? args[0] : 'test'
    ]
    console.log('DEBUG: using cmd:', 'java ' + cmd.join(' '))
    let karate = childProcess.spawn('java', cmd)
    if (!isDebug) {
        console.log()
        const rl = readline.createInterface({
            input: karate.stdout,
            crlfDelay: Infinity
        })
        let failedFeatureStr = null
        for await (const str of rl) {
            if (str.match(new RegExp(/<<(pass|fail)>>/)) !== null) {
                // console.log(str.substr(str.indexOf('<<pass>>'), str.indexOf('.feature')))
                let path = str.match(new RegExp(/[a-z0-9_\-\/]+.feature/))
                let features = str.match(new RegExp(/feature ([0-9]+) of ([0-9]+):/))
                // let duration = str.match(new RegExp(/time: ([0-9](.[0-9]+)?)/))
                let success = str.indexOf('<<pass>>') !== -1
                let outcome = success ? chalk.green('PASS') : chalk.red('FAIL')
                console.log('   ' + outcome + chalk.gray(' - ' + features[1] + '/' + features[2] + ' - ') + path[0])
                // console.log(duration)
            }
            if (str.indexOf('failed features:') !== -1) {
                failedFeatures = true
                failedFeatureStr = ''
            }
            if (failedFeatureStr !== null && str !== '')
                failedFeatureStr += str
            if (failedFeatureStr !== null && str.match(new RegExp(/([a-z0-9_\-]+.)+:/)) !== null) {
                console.log(chalk.redBright(failedFeatureStr.replace('failed features:', '')))
                console.log(failedFeatureStr)
            }
            // if (str.indexOf('ERROR') !== -1) {
            //     // console.error(chalk.redBright('   ' + str.substr(str.indexOf('ERROR'))))
            // }
        }
    } else {
        karate.stdout.pipe(process.stdout)
        karate.stderr.pipe(process.stderr)
    }

    karate.on('close', code => {
        console.log('')
        if (code == 0)
            console.log(chalk.bold(chalk.green("   Test suite succeeded")))
        else 
            console.log(chalk.bold(chalk.red("   Test suite failed")))

        console.log()
        console.log(chalk.gray(' Karate process exited with code ' + code))
        process.exit(code)
    })
})()
