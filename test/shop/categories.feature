Feature: Shop categories

  Background:
    * call read('../common.feature')
    * configure headers = commonHeaders
  
  Scenario:
    # ─────────────────────────────────────────────────────────────────────────────
    #                           Get many shop categories                           
    # ─────────────────────────────────────────────────────────────────────────────
    Given url baseUrl + 'graphql'
      * text query = 
      """
        {
          getManyShopCategories {
            id
          }
        }
      """
      * request { query: '#(query)' }
      When method post
      Then status 200
      * match $.success == true
      * match $.data.getManyShopCategories[*].id == '#[] #string'