@ignore
Feature:

Scenario:
  * def random = function(){return Math.floor(Math.random() * 20) + 1}
  * def commonHeaders = {Accept: 'application/json', Authorization: '#("Bearer " + masterKey)'}
  * def getParams = 
    """
      function(url) {
        var entries = {};
        url
          .split('?')[1]
          .split('&')
          .map(function(k) {
            return k.split('=')
          })
          .forEach(function(k) {
            entries[k[0]] = k[1]
          });
        return entries;
      }
    """