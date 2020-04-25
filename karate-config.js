function fn() {
    var config = JSON.parse(karate.env)
    karate.log('karate.env system property was:', config)
    karate.configure('connectTimeout', 5000)
    karate.configure('readTimeout', 5000)
    return config
}