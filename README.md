# RetroBox API Test

<center>
<img src="https://raw.githubusercontent.com/intuit/karate/master/karate-core/src/main/resources/karate-logo.svg?sanitize=true" alt="alt" width="100"> 
<p>Using the <a href="https://github.com/intuit/karate">Karate test framework</a></p>
</center>

![Continuous integration](https://github.com/retrobox/api-test/workflows/Continuous%20integration/badge.svg)

# Prelude

To use this, you will need to run your own retrobox-api on your own LAN.  
And with these things online :
- A redis server ([keyvaluer](https://github.com/lefuturiste/keyvaluer) for example)
- A mysql database
- A [Jobatator](https://github.com/lefuturiste/jobatator) server 
- The websocket server ([retrobox/ws](https://github.com/retrobox/websocket-server))

*See in our docs to [know](https://github.com/thingmill/docs) how to do this.*

## How to setup with node.js

First you will need to install Karate, to do that, you can simply use our nodejs script with : `node install.js`.   
This will download the latest version of Karate.

Next, you need to create a `.env` based on the `.env.example`. Add your own API keys and other stuff here.
Don't forget to complete your `CHROME_PATH`, it's very important, many tests use Chrome.

And, you can run Karate with :
`node start.js`, this will test all `.feature` avaible in the `/test` folder.

If you want to debug your own script add `-D` argument after `.js`, so : `node start.js -D`.

## What's the point ?!

To put our API into production, it will have to pass all the tests available in this repo. If a test fails, we know there is a problem and therefore it avoids putting feature into production that does not work or that breaks things.

This will be triggered automatically with the API's CI / CD.

## Available test environments

In `./` folder :

- `./newsletter.feature` # This will test our newsletter bridge with mailchimp.  
- `./base.feature` # This will test all basic route like `/ping`and `/health`.  

In `./accounts/` folder :

- `./login.feature` # This will test a fake login connexion.  

In `./console/` folder :

- `./image.feature` #  This will test if we can add a console image on our dashboard.  

In `./shop/` folder :

- `./categories.feature` # This will create categories, delete it...  
- `./paypal.feature` # This use Google Chrome, it will make a fake payment by paypal.  
- `./shipping.feature` # This will call our api with fake weight and fake country to test if everything is ok.  