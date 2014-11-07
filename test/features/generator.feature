
Feature:
  In order to create a website
  As a user
  I would like to generate a static website

  Scenario:
    Given I have a site at "test/site"
    When I generate the site
    Then the "index.html" file should match "test/expected-site/index.html"
    And the "default.html" file should match "test/expected-site/default.html"
    And the "embedded.html" file should match "test/expected-site/embedded.html"
