Feature: Categories

  Background:
    * url 'https://api.retrobox.tech'

  Scenario: get pong
    Given path 'ping'
    When method get
    Then status 200
    And match response == {success: true}