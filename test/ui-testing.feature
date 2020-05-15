Feature: browser automation 1

Background:
  * configure driver = { type: 'chrome', showDriverLog: true, executable: 'chromium', headless: true, addOptions: ['--no-sandbox'] }

Scenario: try something to test karate ui testing
  Given driver 'https://github.com/login'
  And input('#login_field', 'dummy')
  And input('#password', 'world')
  When submit().click("input[name=commit]")
  Then match html('#js-flash-container') contains 'Incorrect username or password.'
  Then waitForUrl('https://github.com/intuit/karate')