require 'serverspec'
set :backend, :exec

describe file('etc/hostname') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
end

describe file('bin/bash') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 755 }
end

describe file('etc/apt/sources.list') do
  it { should be_file }
  its(:content) { should contain 'deb http://httpredir.debian.org/debian jessie main' }
  its(:content) { should contain 'deb http://httpredir.debian.org/debian jessie-updates main' }
  its(:content) { should contain 'deb http://security.debian.org/ jessie/updates main' }
end

describe file('etc/systemd/network/eth0.network') do
  it { should be_file }
  its(:content) { should contain /Name=eth0/ }
  its(:content) { should contain /DHCP=yes/ }
end

describe file('etc/resolv.conf') do
  it { should be_symlink }
end

describe file('run/systemd/resolve/resolv.conf') do
  it { should be_file }
end

describe file('etc/ssh/sshd_config') do
  it { should be_file }
  its(:content) { should contain /^PermitRootLogin without-password/ }
end

describe file('etc/shadow') do
  it { should be_file }
  its(:content) { should contain /^root:\*:/ }
end

describe file('etc/locale.gen') do
  it { should be_file }
  its(:content) { should contain /en_US.UTF-8/ }
end

describe file('etc/hostname') do
  it { should be_file }
  its(:content) { should contain /^PiBox$/ }
end

describe file('etc/group') do
  it { should be_file }
  its(:content) { should contain /^docker:x:.*:boxp77/ }
  its(:content) { should contain /^boxp77:x:/ }
end

describe file('etc/passwd') do
  it { should be_file }
  its(:content) { should contain /^boxp77:/ }
end

describe file('etc/shadow') do
  it { should be_file }
  its(:content) { should contain /^boxp77:/ }
end

describe file('etc/sudoers.d/user-boxp77') do
  it { should be_file }
  it { should be_mode 440 }
  its(:content) { should contain /^boxp77 ALL=NOPASSWD: ALL$/ }
end

describe file('root/.bash_prompt') do
  it { should be_file }
end

describe file('etc/skel/.bash_prompt') do
  it { should be_file }
end

describe file('etc/skel/.bashrc') do
  it { should be_file }
end

describe file('etc/skel/.profile') do
  it { should be_file }
end

describe file('etc/os-release') do
  it { should be_file }
  its(:content) { should contain /HYPRIOT_OS=/ }
  its(:content) { should contain /HYPRIOT_TAG=/ }
  if ENV.fetch('TRAVIS_TAG','') != ''
    its(:content) { should_not contain /VooRPI/ }
  end
end

describe "Firstboot Systemd Service" do

  it "has a service file" do
    service_file = file('lib/systemd/system/hypriot-firstboot.service')

    expect(service_file).to exist
  end

  it "is enabled" do
    service_symlink = file('lib/systemd/system/multi-user.target.wants/hypriot-firstboot.service')

    expect(service_symlink).to exist
    expect(service_symlink).to be_symlink
    expect(service_symlink).to be_linked_to '../hypriot-firstboot.service'
  end

  it "has a hypriot-firstboot script to execute" do
    executable = file('usr/local/bin/hypriot-firstboot')

    expect(executable).to exist
    expect(executable).to be_executable
  end

  it "has a /etc/firstboot.d config directory" do
    config_dir = file('etc/firstboot.d')

    expect(config_dir).to exist
    expect(config_dir).to be_directory
  end

  it "has a script to regenerate sshd host keys" do
    script = file('etc/firstboot.d/50-regenerate-sshd-host-keys')

    expect(script).to exist
  end

end
