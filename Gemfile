source 'https://rubygems.org'

# Clear VAGRANT_HOME so that we don't accidentally stomp on pre-1.1 data.
ENV.delete 'VAGRANT_HOME'

# Local additions and environment variable overrides go here.
if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# Usually, Vagrant stores data in `~/.vagrant.d`. Unfortunately, Vagrant 1.1
# and newer will automatically "upgrade" the layout of the data store which
# breaks older Vagrant versions. So, we pick a new subdirectory for data
# storage so that the old one is left alone.
ENV['VAGRANT_HOME'] = '/usr/local/var/vagrant/puppet-debugging-kit' if ENV['VAGRANT_HOME'].nil?

gem 'vagrant', :github => 'mitchellh/vagrant', :tag => 'v1.3.1'

# Gems listed in this group are automatically loaded by the Vagrantfile which
# simulates the action of `vagrant plugin`, which is inactive when running
# under Bundler.
group :vagrant_plugins do
  gem 'oscar'
  gem 'sahara'
end
