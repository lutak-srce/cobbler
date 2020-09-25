Facter.add(:cobbler_version) do
  setcode do
    if Facter::Util::Resolution.which('cobbler')
      apache_version = Facter::Util::Resolution.exec('cobbler version 2>&1')
      Facter.debug "Matching cobbler '#{cobbler_version}'"
      %r{^Cobbler (\d+\.\d+\.\d+)}.match(cobbler_version)[1]
    end
  end
end
