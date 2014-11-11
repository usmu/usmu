require 'usmu/ui/console'
require 'open3'

Given(/^I have a site at "([^"]*)"$/) do |location|
  @site = Usmu::Ui::Console.new(['--config', "#{location}/usmu.yml"])
end

When(/^I generate the site$/) do
  @site.execute
end

Then(/^the destination directory should match "([^"]*)"$/) do |test_folder|
  run = %W{diff -qr #{@site.configuration.destination_path} #{test_folder}}
  Open3.popen2e(*run) do |i, o, t|
    output = run.join(' ') + "\n" + o.read
    fail output if t.value != 0
  end
end

Then(/^the modification time for the input file "([^"]*)" should match the output file "([^"]*)"$/) do |input, output|
  input_mtime = File.stat(File.join(@site.configuration.source_path, input)).mtime
  output_mtime = File.stat(File.join(@site.configuration.destination_path, output)).mtime
  expect(input_mtime).to eq(output_mtime)
end
