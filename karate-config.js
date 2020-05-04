function fn() {
    var config = {};
    karate.env
        .split('%;')
        .map(function(k) {
            return k.split('%=')
        })
        .forEach(function(k) {
            config[k[0]] = k[1]
        })
    karate.log('karate.env system property was:', config)
    karate.configure('connectTimeout', 5000)
    karate.configure('readTimeout', 10000)
    return config
}