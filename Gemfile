source 'https://rubygems.org'

# Local additions and environment variable overrides can be placed in:
#     Gemfile.local
eval(File.read("#{__FILE__}.local"), binding) if File.exists? "#{__FILE__}.local"

gem 'vagrant', :git => 'https://github.com/hashicorp/vagrant.git',
  :tag => 'v2.2.5'

# Gems listed in this group are automatically loaded by the Vagrantfile which
# simulates the action of `vagrant plugin`, which is inactive when running
# under Bundler.
group :plugins do
  gem 'oscar', '>= 0.6.0'
end
