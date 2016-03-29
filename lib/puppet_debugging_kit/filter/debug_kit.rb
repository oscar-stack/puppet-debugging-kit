require_relative '../logging'

class PuppetDebuggingKit::Filter::DebugKit
  # Quick and dirty representation of a version number.
  Version = Struct.new(:major, :minor, :patch) do
    def to_s
      [self.major, self.minor, self.patch].join('.')
    end

    def series
      [self.major, self.minor].join('.')
    end
  end

  def set_config(root_config)
    @root_config = root_config
    # Return empty hash if not found.
    @debug_kit   = root_config.delete('debug_kit') {|k| Hash.new}

    @logger = PuppetDebuggingKit::Logging.global_logger
  end

  def run
    vms = @root_config.fetch('vms', [])

    @root_config['vms'] = vms.map { |vm_hash| filter_vm(vm_hash) }
    return @root_config
  end

  private

  def filter_vm(vm_data)
    # If a VM definition does not have the `debug-kit` flag set, don't process
    # it.
    #
    # TODO: Right now this is a boolean value. Investigate allowing it to be a
    # string or hash containing debug kit data. This would alleviate the need to
    # overload the VM name to the point where it is cumbersome to type.
    return vm_data unless vm_data.delete('debug-kit')

    type, version, role = parse_name(vm_data['name'])
    if type.nil?
      @logger.warn "Failed to parse debug kit info from: #{vm_data['name']}"
      return vm_data
    end

    # If no hostname given, set a default.
    vm_data['hostname'] ||= "#{vm_data['name']}.puppetdebug.vlan"

    # Ensure the VM definition has an array of provisioners
    vm_data['provisioners'] ||= []

    # NOTE: Assumes `pe_bootstrap` and `pe_agent` are the only provisioners we
    # need to work with and that there is only one copy attached to the
    # machine.
    provisioner = if (role == 'agent') && (version.major.to_i >= 2015)
      # Used for PE 2015.x and newer since tarball installers are deprecated.
      'pe_agent'
    else
      'pe_bootstrap'
    end

    index = vm_data['provisioners'].find_index {|p| p['type'] == provisioner}
    if index.nil?
      # No pe_bootstrap provisioner present, add one.
      vm_data['provisioners'].push puppet_provisioner({'type' => provisioner}, type, version, role)
    else
      # Add defaults parsed from the VM name to the existing provisioner.
      vm_data['provisioners'][index] = puppet_provisioner(vm_data['provisioners'][index].dup, type, version, role)
    end

    return vm_data
  end

  def parse_name(name)
    # For now, we use a very strict regex that expects three dash-separated
    # inputs.
    #
    # TODO: Revisit this and decide if a more flexible scheme is needed.
    match = name.match /([[:alpha:]]+)-([[:alnum:]]+)-([[:alpha:]]+)/

    # If the match failed, return nils as an error case.
    #
    # FIXME: Should probably just raise an error as there is more than one
    # thing that can go wrong with name parsing.
    return [nil, nil, nil] if match.nil?

    type, version, role = match[1..3]
    version = parse_version(version)

    return [type, version, role]
  end

  def parse_version(version)
    # TODO: Version will eventually include non-digit things, such as `HEAD` or
    # `nightly`, or `g<SHA>`, so this will need to expand beyond alphanumeric
    # parsing.
    #
    # FIXME: Needs validation and error handling.
    if m = version.match(/(\d+)(\d)(nightly)/) then
      # Nightly build. Handles both 3x and 2015+
      major, minor, patch = m[1..-1]
    elsif m = version.match(/(\d{4})(\d)(\d+)/) then
      # A 2015.2.0 release or newer.
      major, minor, patch = m[1..-1]
    else
      # Fall back to 2.x/3.x behavior
      major, minor, *patch = version.split('')
      patch = patch.join('')
    end

    return Version.new(major, minor, patch)
  end

  # Merges information extracted by this filter into the pe_build provisioners.
  # This operation only modifies data where there are no existing values.
  #
  # TODO: Currently, only handles the `pe_bootstrap` provisioner. Will
  # eventually need to expand to handle PE nightlies and Puppet Open Source.
  def puppet_provisioner(provisioner, type, version, role)
    # For PE 2015.x agents.
    if provisioner['type'] == 'pe_agent'
      provisioner['master_vm'] ||= "#{type}-#{version.to_s.gsub('.','')}-master"
      provisioner['version']   ||= (version.patch == 'nightly' ? 'current' : version.to_s)
      return provisioner
    end

    case version.patch
    when 'nightly'
      # FIXME: This part is going to ge complicated. Re-write as a separate
      # method.
      if provisioner['version'].nil?
        provisioner['series'] ||= version.series
        # FIXME: Raise error if either of these is nil.
        provisioner['version_file'] = @debug_kit.fetch('nightlies', {}).fetch('pe', {}).fetch('version_file', nil)
      end
      provisioner['download_root'] ||= @debug_kit.fetch('nightlies', {}).fetch('pe', {}).fetch('download_root', nil)
    else
      # TODO: When /\d+/. Else, raise error.
      provisioner['version'] ||= version.to_s
    end

    provisioner['role']    ||= role.intern
    case provisioner['role']
    when :master
      # Starting with 2015, we use the pe_agent provisioner which handles
      # cert signing.
      provisioner['autosign'] ||= (version.major.to_i < 2015)
    when :agent
      # Set a default master for the agent to talk to.
      provisioner['master'] ||= "#{type}-#{version.to_s.gsub('.','')}-master.puppetdebug.vlan"
    end

    return provisioner
  end
end
