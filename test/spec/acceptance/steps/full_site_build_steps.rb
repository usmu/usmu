require 'usmu/ui/console'
require 'open3'

step 'I have a site at :location' do |location|
  @location = "#{location}/usmu.yml"
end

step 'I generate the site' do
  @site = Usmu::Ui::Console.new(['generate', '--config', @location])
end

step 'the destination directory should match :test_folder' do |test_folder|
  run = %W{diff -qr #{@site.configuration.destination_path} #{test_folder}}
  Open3.popen2e(*run) do |i, o, t|
    output = run.join(' ') + "\n" + o.read
    fail output if t.value != 0
  end
end

step 'the modification time for the input file :input should match the output file :output' do |input, output|
  input_mtime = File.stat(File.join(@site.configuration.source_path, input)).mtime
  output_mtime = File.stat(File.join(@site.configuration.destination_path, output)).mtime
  expect(input_mtime).to eq(output_mtime)
end
