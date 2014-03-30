source 'https://rubygems.org'
ruby '2.0.0'

# Local additions and environment variable overrides go here.
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

gem 'vagrant', :github => 'mitchellh/vagrant', :tag => 'v1.5.1'

# Gems listed in this group are automatically loaded by the Vagrantfile which
# simulates the action of `vagrant plugin`, which is inactive when running
# under Bundler.
group :plugins do
  gem 'vagrant-hosts', '>= 2.1.3' # Version required for Vagrant 1.5.x
  gem 'vagrant-auto_network'
  gem 'vagrant-pe_build'
  gem 'vagrant-config_builder', '>= 0.7.0' # Version required for deep_merge
  gem 'oscar'
  gem 'vagrant-vbox-snapshot'
end
