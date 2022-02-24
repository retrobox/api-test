Feature: console images test

  Background:
    * call read('../common.feature')
    * configure headers = commonHeaders

  Scenario: Test console images
    # ─────────────────────────────────────────────────────────────────────────────
    #                            Get consoles versions                             
    # ─────────────────────────────────────────────────────────────────────────────
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
      * match $.success == true
      * match $.data == { getConsoleVersions: #array }
      * match $.data.getConsoleVersions[*].id == '#[] #string'
      * match $.data.getConsoleVersions[*].id == '#[] #regex ^(\\d+\\.)?(\\d+\\.)?(\\*|\\d+)$'
      * def consoleVersion = $.data.getConsoleVersions[0].id

    # ──────────────────────────────────────────────────────────────────────────────
    #                              Store console image                              
    # ──────────────────────────────────────────────────────────────────────────────
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
      * def softwareVersion = random(1, 20) + "." + random(1, 20)
      * def size = random(1000, 3500)
      * def hash = sha256('test')
      * print 'Hash is:', hash
      * def variables = 
      """
      {
        input: {
          console_version: '#(consoleVersion)',
          software_version: '#(softwareVersion)',
          size: '#(1*size)',
          hash: '#(hash)'
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

    # ──────────────────────────────────────────────────────────────────────────────
    #                            Get many console images                            
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getManyConsoleImages(all: true) {
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

    # ──────────────────────────────────────────────────────────────────────────────
    #                             Update console images                             
    # ──────────────────────────────────────────────────────────────────────────────
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

    # ──────────────────────────────────────────────────────────────────────────────
    #                  Get many console image to verify the store                   
    # ──────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getManyConsoleImages(all: true) {
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

    # ──────────────────────────────────────────────────────────────────────────────
    #                            Destroy console images                             
    # ──────────────────────────────────────────────────────────────────────────────
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
