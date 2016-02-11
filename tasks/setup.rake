# This rakefile contains tasks for automating the setup of the debugging kit.
namespace :setup do
  desc 'Install requirements into a global Vagrant setup'
  task :global do
    %w[oscar].each do |plugin|
      Kernel.system 'vagrant', 'plugin', 'install', plugin
    end
  end

  desc 'Install requirements into a local sandbox managed by Bundler'
  task :sandboxed do
    Kernel.system 'bundle', 'install', '--binstubs', '--path=.bundle/lib'
  end


  POSS_ROOT = File.join('src', 'puppetlabs')
  POSS_PROJECTS = ['puppet', 'facter', 'hiera']

  desc 'Clone Puppet Open Source projects into a folder that can be shared with VMs'
  task :poss => POSS_PROJECTS.map {|proj| File.join(POSS_ROOT, proj)}

  directory POSS_ROOT
  POSS_PROJECTS.each do |proj|
    file File.join(POSS_ROOT, proj) => POSS_ROOT do |dir|
      Kernel.system 'git', 'clone',
        "https://github.com/puppetlabs/#{proj}",
        dir.to_s
    end
  end
end
