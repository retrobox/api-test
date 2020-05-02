const childProcess = require('child_process')
const dotEnv = require('dotenv')
const chalk = require("chalk")
const readline = require('readline')
const request = require('request')

dotEnv.config()

let config = {
    baseUrl: process.env.API_ENDPOINT,
    stailbaseUrl: process.env.STAIL_EU_API,
    masterKey: process.env.API_MASTER_KEY,
    loginUserID: process.env.LOGIN_USER_ID,
    loginPassword: process.env.LOGIN_PASSWORD
}

if (config.baseUrl.substr(config.baseUrl.length - 1) !== '/')
    config.baseUrl += "/"

const waitUntilServerStarted = () => {
    return new Promise(resolve => {
        request
            .get(config.baseUrl)
            .on('response', () => {
                return resolve()
            })
            .on('error', () => { 
                setTimeout(() => {
                    return waitUntilServerStarted()
                }, 500)
            })
    })
}

(async () => {
    await waitUntilServerStarted()
    console.log('> Got connexion')

    let cmd = ['-cp', 'karate.jar:.', `-Dkarate.env=${JSON.stringify(config)}`, 'com.intuit.karate.Main', '-T', '1']

    if (process.argv.length > 2 && process.argv[2] != "-D") {
        cmd.push(process.argv[2])
    } else {
        cmd.push('test')
    }
   
    console.log('DEBUG: using cmd:', 'java ' + cmd.join(' '))

    let karate = childProcess.spawn('java', cmd)

    if (process.argv.filter(a => a === "-D").length === 0) {
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
                console.log('   ' + outcome + ' - ' + features[1] + '/' + features[2] + ' - ' + path[0])
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
