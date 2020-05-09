Feature: account login test

  Background:
    * call read('../common.feature')

  Scenario: Test account login
    # ──────────────────────────────────────────────────────────────────────────────
    #                               Get stail.eu url                                
    # ──────────────────────────────────────────────────────────────────────────────

    Given url baseUrl + 'account/login'
    When method get
    Then status 200
    * match $.data.url == '#string'
    * def dataUrl = $.data.url
    * def queryParams = getParams(dataUrl)
    * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #                    test login api and get the accessToken                     
    # ──────────────────────────────────────────────────────────────────────────────

    # Account ID : LOGIN_USER_ID in .env
    # Account password : LOGIN_PASSWORD in .env

    Given url stailbaseUrl + 'login'
      * print loginUserID
      * print loginPassword
      When request { login:'#(loginUserID)', password:'#(loginPassword)' }
      And method post
      Then status 200
      And print 'Response is: ', response
      * match $.data.token == '#string'
      * def accessToken = $.data.token
      * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #           call stail api w/ params code accessToken & get oauthToken                  
    # ──────────────────────────────────────────────────────────────────────────────
  
    Given url stailbaseUrl + 'oauth/authorize/setup'
      * print accessToken
      * print queryParams.client_id
      When request { client_id:'#(queryParams.client_id)', redirect_uri:"https://retrobox.tech/login/execute", "scope":"read-profile read-email" }
      * header Authorization = 'Bearer ' + accessToken
      And method post
      Then status 200
      And print 'Response is: ', response
      * match $.data.auth.token == '#string'
      * def oauthToken = $.data.auth.token
      * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #                     get JWT key provide by the stail api                      
    # ──────────────────────────────────────────────────────────────────────────────
   
		Given url baseUrl + 'account/execute'
      * print oauthToken
      When request { code:'#(oauthToken)' }
      * header Accept-Language = 'en'
      And method post
      Then status 200
      And print 'Response is: ', response
      * match $.data.token == '#string'
      * match $.data.user.id == '#string'
      * def jwtToken = $.data.token
      * def userId = $.data.user.id 
      * print jwtToken
      * print userId
      * match $.success == true

    # ──────────────────────────────────────────────────────────────────────────────
    #     Call RetroBox api with the JWT token to check if it's the correct one     
    # ──────────────────────────────────────────────────────────────────────────────

    Given url baseUrl + 'graphql'
      * text query = 
      """
        query ($id: String!) {
          getOneUser(id: $id) {
            id
            last_username
            last_email
          }
        }
      """
      * request {query: '#(query)', variables: {id: '#(userId)'}}
      * header Authorization = 'Bearer ' + jwtToken
      When method post
      Then status 200
      * match $.data.getOneUser.last_email == loginUserID

Scenario: Test login failed
    # ──────────────────────────────────────────────────────────────────────────────
    #                               Test login failed                               
    # ──────────────────────────────────────────────────────────────────────────────
   
	Given url baseUrl + 'account/execute'
      * def oauthToken = 123456789
      When request { code:'#(oauthToken)' }
      * header Accept-Language = 'en'
      And method post
      Then status 400
      * match $.success == false