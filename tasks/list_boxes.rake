require 'yaml'

namespace :list do
  desc 'List Available Boxes'
  task :boxes do
    box_files = Dir['config/boxes.yaml', 'data/puppet_debugging_kit/**/boxes.yaml']
    all_boxes = box_files.map {|f| YAML.load_file(f)['boxes']}.reduce(:merge)

    all_boxes.each_key { |boxname| puts boxname }
  end
end
