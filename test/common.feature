@ignore
Feature:

Scenario:
  * def random = function(){return Math.floor(Math.random() * 20) + 1}
  * def commonHeaders = {Accept: 'application/json', Authorization: '#("Bearer " + masterKey)'}