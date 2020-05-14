Feature: Test newsletter

  Background:
    * call read('./common.feature')
  
    Scenario: check
    # ──────────────────────────────────────────────────────────────────────────────
    #                         Check if a user already exist                         
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'newsletter/subscribe'
    #MD5 key for email = b0ec3fca29ebbfa0a277aaff1bba8641
    When request { email:'patrick@balkany.fr' }
    When method post
    Then status 400
    * match $.errors.[0].title == "Member Exists"
    * match $.success == false

    # ──────────────────────────────────────────────────────────────────────────────
    #                      Add a random user to our mail list                       
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'newsletter/subscribe'
    * def emailToSubscribe = random() + "@ignored-events-for.test"
    When request { email:'#(emailToSubscribe)' }
    When method post
    Then status 200
    * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #                                Delete the user                                
    # ──────────────────────────────────────────────────────────────────────────────
    #hash the fake user email with md5
    * def hash = md5(emailToSubscribe)
    * print hash
    Given url 'https://us18.api.mailchimp.com/3.0/lists/d9a684ec79/members/' + hash
    * print mailchimpKey
    * def loginPayload = { username: 'thingmill', password: '#(mailchimpKey)' }
    * print loginPayload
    * header Authorization = basicAuth(loginPayload)
    When method delete
    Then status 204