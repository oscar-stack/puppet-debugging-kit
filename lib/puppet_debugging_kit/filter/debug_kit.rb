require_relative '../logging'

class PuppetDebuggingKit::Filter::DebugKit

  def set_config(root_config)
    @root_config = root_config
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

    # NOTE: Assumes `pe_bootstrap` is the only provisioner we need to work with
    # and that there is only one copy of it attached to the machine.
    index = vm_data['provisioners'].find_index {|p| p['type'] == 'pe_bootstrap'}
    if index.nil?
      # No pe_bootstrap provisioner present, add one.
      vm_data['provisioners'].push puppet_provisioner({'type' => 'pe_bootstrap'}, type, version, role)
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
    match = name.match /([[:alpha:]]+)-([[:digit:]]+)-([[:alpha:]]+)/

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
    # NOTE: We assume that Puppet has no min or max versions that extend into
    # double digits. So far, this assumption is consistent with history.
    #
    # TODO: Version will eventually include non-digit things, such as `HEAD` or
    # `nightly`, or `g<SHA>`, so this will need to expand beyond alphanumeric
    # parsing.
    #
    # FIXME: Needs validation and error handling.
    min, max, *patch = version.split('')

    return [min, max, patch.join('')].join('.')
  end

  # Merges information extracted by this filter into the pe_bootstrap
  # provisioner. This operation only modifies data where there are no
  # existing values.
  #
  # TODO: Currently, only handles the `pe_bootstrap` provisioner. Will
  # eventually need to expand to handle PE nightlies and Puppet Open Source.
  def puppet_provisioner(provisioner, type, version, role)
    # If an explicit filename is set, then we don't need to add a version.
    provisioner['version'] ||= version     if provisioner['filename'].nil?
    provisioner['role']    ||= role.intern

    case provisioner['role']
    when :agent
      # Set a default master for the agent to talk to.
      provisioner['master'] ||= "#{type}-#{version.gsub('.','')}-master.puppetdebug.vlan"
    end

    return provisioner
  end
end
