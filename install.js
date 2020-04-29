/* 
- Do a HTTP request https://api.github.com/repos/intuit/karate/releases
- Get the latest release, look at the json
- Download the url
- Unzip
- Rename/move the binary
- And voila !
*/

const fetch = require("node-fetch")
const fs = require('fs')
const request = require('request')
const progress = require('request-progress')
const progressBar = require('cli-progress')
const prettyBytes = require('pretty-bytes')
const chalk = require('chalk')

const fileName = "karate.jar"

const bar = new progressBar.SingleBar({
  format: '> ' + fileName + ' |' + chalk.green('{bar}') + '| {percentage}% '
    + chalk.gray('||') + ' {value}/{total} Bytes ' + chalk.gray('||')
    + 'Speed: ' + chalk.cyan('{speed}/sec'),
  barCompleteChar: '\u2588',
  barIncompleteChar: '\u2591',
  hideCursor: true
});
let total = null

fetch("https://api.github.com/repos/intuit/karate/releases").then(async (response) => {
  let json = await response.json()
  let url = json[0].assets.filter(r => r.name.indexOf('.jar') != -1)[0].browser_download_url
  console.log("> Downloading " + url)
  console.log()
  progress(request(url))
  .on('progress', function (state) {
      if (total === null) {
        total = state.size.total
        bar.start(total, 0, {speed: "N/A"})
      }
      bar.update(state.size.transferred, {
        speed: state.speed != null ? prettyBytes(state.speed) : "N/A"
      })
  })
  .on('error', function (err) {
    console.error(err);
  })
  .on('end', function () {
    bar.update(total);
    console.log()
    console.log()
    console.log("> Downloaded " + fileName);
    bar.stop()
  })
  .pipe(fs.createWriteStream(fileName));
 })

