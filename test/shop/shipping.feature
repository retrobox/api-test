Feature: Get the price by Colissimo and Chronopost

  Background:
    * call read('../common.feature')
    * configure headers = commonHeaders
  
  Scenario: Get the price for a random weight and a random country with the Colissimo
    # ──────────────────────────────────────────────────────────────────────────────
    #                             Get a random country                              
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'countries/en'
    When method get
    Then status 200
    * def countries = $.data
    * match $.data[*].name == '#[] #string'
    * def code = randomElement(countries).code
    * print code
    * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #                  Call the Colissimo api with a random weight                  
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'shop/shipping-prices'
    Given param country = code
    * def randomWeight = random(1000, 10000)
    Given param weight = randomWeight
    And param postal_code = '61000'
    When method get
    Then status 200
    * def rawshippingPrice = $.data.colissimo
    * def shippingPrice = rawshippingPrice / 100
    * print 'Price:', shippingPrice
    * def kgWeight = randomWeight / 1000
    * print 'Weight:', kgWeight
    * print 'Country:', code
    #meh ?
    #* def result = "A parcel that weights" + weight + "costs" + shippingPrice + "Euros TTC to send to" + code
    #* def result = 'A parcel that weights #(weight) costs #(shippingPrice) Euros TTC to send to #(code)'
    #* print result
    * match $.success == true
  Scenario: Get the price for a Chronopost express parcel
    # ─────────────────────────────────────────────────────────────────────────────────────────────────
    #  Get the price for a random weight, a fixed country (FR) with Chronopost (France to France test)
    # ─────────────────────────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'shop/shipping-prices'
    Given param country = 'FR'
    * def randomWeight = random(1000, 10000)
    Given param weight = randomWeight
    And param postal_code = '61000'
    When method get
    Then status 200
    * def rawshippingPrice = $.data.chronopost
    * match rawshippingPrice == '#number'
    * def shippingPrice = rawshippingPrice / 100
    * print 'Price:', shippingPrice
    * def kgWeight = randomWeight / 1000
    * print 'Weight:', kgWeight
    * print 'Country: FR'
    * match $.success == true
    # ────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    #  Get the price for a random weight, a fixed country (FR) and a fixed postal code with Chronopost (Corsica test)
    # ────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'shop/shipping-prices'
    Given param country = 'FR'
    * def randomWeight = random(1000, 10000)
    Given param weight = randomWeight
    And param postal_code = '20000'
    When method get
    Then status 200
    * match $.data.chronopost == 0
    * print 'Price: 0'
    * def kgWeight = randomWeight / 1000
    * print 'Weight:', kgWeight
    * print 'Country: FR in corsica'
    * match $.success == true
    # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    #  Get the price for a random weight, a fixed country (Germany) and a random postal code with Chronopost (EU test)
    # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'shop/shipping-prices'
    Given param country = 'DE'
    * def randomWeight = random(1000, 10000)
    Given param weight = randomWeight
    And param postal_code = '20000'
    When method get
    Then status 200
    * def rawshippingPrice = $.data.chronopost
    * match rawshippingPrice == '#number'
    * def shippingPrice = rawshippingPrice / 100
    * print 'Price:', shippingPrice
    * def kgWeight = randomWeight / 1000
    * print 'Weight:', kgWeight
    * print 'Country: DE'
    * match $.success == true