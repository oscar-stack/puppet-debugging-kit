source 'https://rubygems.org'
ruby '2.0.0'

# Local additions and environment variable overrides go here.
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

gem 'vagrant', :github => 'mitchellh/vagrant', :tag => 'v1.6.3'

# Gems listed in this group are automatically loaded by the Vagrantfile which
# simulates the action of `vagrant plugin`, which is inactive when running
# under Bundler.
group :plugins do
  gem 'oscar', '>= 0.4'
  gem 'vagrant-hosts', '>= 2.1.4' # Version required for Vagrant 1.6.x
  gem 'vagrant-auto_network'
  gem 'vagrant-pe_build'
  gem 'vagrant-config_builder'
  gem 'vagrant-vbox-snapshot'
end
