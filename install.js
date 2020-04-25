/* 
- Do a HTTP request https://api.github.com/repos/intuit/karate/releases
- Get the latest release, look at the json
- Download the url
- Unzip
- Rename/move the binary
- And voila !
*/

const fetch = require("node-fetch");
var fs = require('fs');
var request = require('request');
var progress = require('request-progress');


fetch("https://api.github.com/repos/intuit/karate/releases", {
  "method": "GET"
})
.then(async (response) => {
    let json = await response.json()
    let url = json[0].assets.filter(r => r.name.indexOf('.jar') != -1)[0].browser_download_url
    console.log(url)
    progress(request(url), {
    })
    .on('progress', function (state) {
        console.log('progress', state);
    })
    .on('error', function (err) {
      console.error(err);
    })
    .on('end', function () {
      console.log("FIN CONNARD");
    })
    .pipe(fs.createWriteStream("karate.jar"));
 })

