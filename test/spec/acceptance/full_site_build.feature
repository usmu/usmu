
Feature:
  In order to create a website
  As a user
  I would like to generate a static website

  Scenario:
    Given I have a site at "test/site"
    When I generate the site
    Then the destination directory should match "test/expected-site"
    And the modification time for the input file "index.md" should match the output file "index.html"
