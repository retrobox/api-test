@ignore
Feature:

Scenario:
  #* def random = function(){return (Math.floor(Math.random() * 20) + 1).toString()}
  * def random = 
    """
      function(min, max) {
        if (min === undefined) {
          min = 0
        }
        if (max === undefined) {
          max = 10000
        }
        return Math.floor(Math.random()*(max-min+1)+min).toString()
      }
    """
  * def commonHeaders = {Accept: 'application/json', Authorization: '#("Bearer " + masterKey)'}
  * def randomElement = function(items){return items[Math.floor(Math.random()*items.length)]}
  * def toFixed = function(number){return parseFloat(number).toFixed(2)}
  * def md5 = function(str){return Java.type("org.apache.commons.codec.digest.DigestUtils").md5Hex(str)}
  * def sha256 = function(str){return Java.type("org.apache.commons.codec.digest.DigestUtils").sha256Hex(str)}
  * def splitElement = function(){return str.split(".")[0]}
  * def randomText = 
    """
      function(size) {
        var content = read('../ressources/lorem.txt')
        var max = content.length - size
        var position = Math.floor(Math.random()*(max+1))
        if (size > content.length) {
          return "MAN KESTUFOU ?"
        }
        content = content.substr(position, size)
        if (content.charAt(0) === ' ') {
          content = content.substr(1)
        }
        return content
      }
    """
  * def basicAuth = 
    """
      function (creds) {
        var temp = creds.username + ':' + creds.password;
        var Base64 = Java.type('java.util.Base64');
        var encoded = Base64.getEncoder().encodeToString(temp.bytes);
        return 'Basic ' + encoded;
      }
    """
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
  * def encodeBase64FromBytes = 
    """
      function(bytes) {
        var encoder = Java.type('java.util.Base64')
          .getUrlEncoder()
          .withoutPadding()
        return new java.lang.String(encoder.encode(bytes))
      }
    """
  * def encodeBase64 = function(str) {return encodeBase64FromBytes(str.getBytes("UTF-8"))}
  * def apiJwtKey = "hello"
  * def generateJWTFromPayload = 
    """
      function(payload) {
        var headerEncoded = encodeBase64(JSON.stringify({alg: "HS256", typ: "JWT"}))
        var payloadEncoded = encodeBase64(payload)
        var toSign = headerEncoded + '.' + payloadEncoded
        var sha256HMAC = Java.type('javax.crypto.Mac').getInstance("HmacSHA256")
        var secretKey = new javax.crypto.spec.SecretKeySpec(apiJwtKey.getBytes("UTF-8"), "HmacSHA256")
        sha256HMAC.init(secretKey)
        var signature = encodeBase64FromBytes(sha256HMAC.doFinal(toSign.getBytes("UTF-8")))
        var token = toSign + '.' + signature
        return token
      }
    """
  * def generateJWT = 
    """
      function(id, isAdmin) {
        return generateJWTFromPayload('{"id":"' + id + '","is_admin":' + isAdmin + '}')
      }
    """