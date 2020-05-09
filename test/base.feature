Feature: test basic routes
  Scenario: get pong
    Given url baseUrl + 'ping'
    When method get
    Then status 200
    And match response == {success: true}
  Scenario: check connexions & issue
    Given url baseUrl + 'health'
    When method get
    #issue
    * match $.data.have_issues == false
    #connexions
    * match $.data.connexions.jobatator == true
    * match $.data.connexions.mysql == true
    * match $.data.connexions.redis == true
    * match $.data.connexions.websocket_server == true
    Then status 200
    And match $.success == true