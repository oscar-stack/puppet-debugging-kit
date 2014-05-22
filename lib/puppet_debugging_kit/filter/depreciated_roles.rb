require_relative '../logging'

class PuppetDebuggingKit::Filter::DepreciatedRoles

  def set_config(root_config)
    @root_config = root_config
  end

  def run
    depreciated_roles, @root_config['roles'] = filter_roles(@root_config['roles'])
    vms = @root_config.fetch('vms', [])

    return @root_config if depreciated_roles.empty? || vms.empty?

    logger = PuppetDebuggingKit::Logging.global_logger
    used_roles(vms, depreciated_roles).each do |role, vms|
      message = depreciated_roles[role] +
        "\nThe following VMs use this role:\n" +
        vms.map{|n| '  - ' + n}.join("\n")
      logger.warn(message)
    end

    return @root_config
  end

  private

  def filter_roles(roles)
    depreciated_roles = roles.map do |name, role|
      if role.has_key?('depreciated-role')
        message = role.delete('depreciated-role')

        if message.nil?
          {name => "Role #{name} is depreciated and will be removed in an upcoming version."}
        else
          {name => "Role #{name} is depreciated: #{message}"}
        end
      else
        nil
      end
    end.compact.reduce({}, :merge)

    return [depreciated_roles, roles]
  end

  def used_roles(vm_list, depreciated_roles)
    in_use = {}

    vm_list.each do |vm_config|
      next if vm_config['roles'].nil?

      (vm_config['roles'] & depreciated_roles.keys).each do |role|
        in_use[role] ||= []
        in_use[role] << vm_config['name']
      end
    end

    return in_use
  end
end
