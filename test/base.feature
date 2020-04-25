Feature: test basic routes
  Scenario: get pong
    Given url baseUrl + 'ping'
    When method get
    Then status 200
    And match response == {success: true}