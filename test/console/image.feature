Feature: console images test

  Background:
    * call read('../common.feature')
    * configure headers = commonHeaders

  Scenario: Test console images
    # ===========================
    # get console versions
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getConsoleVersions {
            id
          }
        }
      """
      * request { query: '#(query)' }
      When method post
      Then status 200
      * def consoleVersion = $.data.getConsoleVersions[0].id
      * match $.success == true
      * match $.data == { getConsoleVersions: #array }
      * match $.data.getConsoleVersions[*].id == '#[] #string'
      * match $.data.getConsoleVersions[*].id == '#[] #regex ^(\\d+\\.)?(\\d+\\.)?(\\*|\\d+)$'

    # ===========================
    # store console image
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        mutation ($input: ConsoleImageStoreInput!) {
          storeConsoleImage(image: $input) {
            id
            saved
          }
        }
      """
      * def softwareVersion = random() + "." + random()
      * def variables = 
      """
      {
        input: {
          console_version: '#(consoleVersion)',
          software_version: '#(softwareVersion)'
        }
      }
      """
      * request {query: '#(query)', variables: '#(variables)'}
      When method post
      Then status 200
      * match $.success == true
      * match $.data.storeConsoleImage.id == '#string'
      * match $.data.storeConsoleImage.saved == true
      * def imageId = $.data.storeConsoleImage.id

    # ===========================
    # get many console image
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getManyConsoleImages {
            id
            console_version
            software_version
            version
          }
        }
      """
      * request {query: '#(query)'}
      When method post
      Then status 200
      * match $.success == true
      * match $.data.getManyConsoleImages contains {id: '#(imageId)', software_version: '#(softwareVersion)', console_version: '#(consoleVersion)', version: '#("h" + consoleVersion + "-s" + softwareVersion)'}

    # ===========================
    # update console image
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        mutation ($input: ConsoleImageUpdateInput!) {
          updateConsoleImage(image: $input)
        }
      """
      * def imageDescription = "this is a description"
      * def variables = 
      """
      {
        input: {
          id: '#(imageId)',
          description: '#(imageDescription)',
          software_version: '#(softwareVersion)'
        }
      }
      """
      * request {query: '#(query)', variables: '#(variables)'}
      When method post
      Then status 200
      * match $.success == true
      * match $.data.updateConsoleImage == true

    # ===========================
    # get many console image
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getManyConsoleImages {
            id
            description
          }
        }
      """
      * request {query: '#(query)'}
      When method post
      Then status 200
      * match $.success == true
      * match $.data.getManyConsoleImages contains {id: '#(imageId)', description: '#(imageDescription)'}

    # ===========================
    # destroy console image
    # ===========================
    Given url baseUrl + 'graphql'
      * text query = 
      """
        mutation ($id: ID!) {
          destroyConsoleImage(id: $id)
        }
      """
      * def variables = {id: '#(imageId)'}
      * request {query: '#(query)', variables: '#(variables)'}
      When method post
      Then status 200
      * match $.success == true
      * match $.data.destroyConsoleImage == true