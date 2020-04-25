Feature: console images test
  Scenario: Get console versions
    * text query = 
    """
      {
        getConsoleVersions{
          id
        }
      }
    """
    Given url baseUrl + 'graphql'
    And request { query: '#(query)' }
    And header Accept = 'application/json'
    And header Authorization = "Bearer " + masterKey
    When method post
    Then status 200
    * match $.success == true
    * match $.data == { getConsoleVersions: #array }