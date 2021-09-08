Facter.add(:cobbler_version) do
  setcode do
    if Facter::Util::Resolution.which('cobbler')
      cobbler_version = Facter::Util::Resolution.exec('cat /etc/cobbler/version | grep "version "')
      Facter.debug "Matching cobbler '#{cobbler_version}'"
      %r{^version = (\d+\.\d+\.\d+)}.match(cobbler_version)[1]
    end
  end
end
