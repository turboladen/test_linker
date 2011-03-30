Feature: Get info from TestLink
  As a TestLink API user
  I want to get info from the TestLink server
  So that I can use the info in reports and such

  Scenario Outline: Get a list of projects
    Given I have a TestLink server with API version <version>
    When I ask for the list of projects
    Then I get a list of projects

  Scenarios:
    | version    |
    | 1.0 Beta 5 |
    | 1.0        |

  Scenario Outline: Get a list of test plans
    Given I have a TestLink server with API version <version>
    When I ask for the list of projects
    And I ask for a list of test plans
    Then I get a list of test plans

  Scenarios:
    | version    |
    | 1.0 Beta 5 |
    | 1.0        |

