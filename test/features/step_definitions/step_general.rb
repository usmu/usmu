
Given(/^I have a site at "([^"]*)"$/) do |location|
  @site = Usmu.new(location)
end

When(/^I generate the site$/) do
  @site.generate
end

Then(/^the "([^"]*)" file should match "([^"]*)"$/) do |original, test|

end
