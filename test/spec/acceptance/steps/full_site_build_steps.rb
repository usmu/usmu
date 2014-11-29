require 'usmu/ui/console'
require 'open3'

step 'I have a site at :location' do |location|
  @location = "#{location}/usmu.yml"
end

step 'I run usmu with the arguments :args' do |args|
  args = args.split(' ')
  if @location
    args << '--config' << @location
  end
  @site = Usmu::Ui::Console.new(args)
end

step 'the directory :destination should match :test_folder' do |destination, test_folder|
  run = %W{diff -qr --strip-trailing-cr #{destination} #{test_folder}}
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
