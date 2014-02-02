require 'puppet/provider/neutron'
require 'facter'

begin
  authenv = Puppet::Provider::Neutron.get_authenv
  list = Puppet::Provider::Neutron.withenv(authenv) do
    Facter::Util::Resolution.exec('neutron net-list --format=csv --column=id' +
      ' --column=name --quote=none 2>/dev/null')
  end

  if !list.nil?
    (list.split("\n")[1..-1] || []).compact \
        .map {|line| line.strip.split(',', 2) }.each do |id, name|
      Facter.add(:"neutron_network_id_#{name}") do
        setcode do
          id
        end
      end
    end
  end
rescue
  # Probably doesn't have neutron installed
end