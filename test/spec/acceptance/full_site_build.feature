
Feature:
  In order to create a website
  As a user
  I would like to generate a static website

  Scenario:
    When I run usmu with the arguments "init tmp"
    Then the directory "tmp" should match "share/init-site"


  Scenario:
    Given I have a site at "test/site"
    When I run usmu with the arguments "generate"
    Then the directory "test/site/site" should match "test/expected-site"
    And the modification time for the input file "index.md" should match the output file "index.html"
