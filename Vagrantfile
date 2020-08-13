# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Check required vagrant dependencies plugins and install them
#
required_plugins = %w( vagrant-disksize )
plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    # restart vagrant to apply installed plugins
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu2004"

  # override default disk size
  # requires 'vagrant plugin install vagrant-disksize'
  config.disksize.size = '30GB'

  # authorize self in test sandbox
  # Copy local public SSH Key to VM
  id_rsa_ssh_key_pub = File.read(File.join(Dir.home, ".ssh", "id_rsa.pub"))
  config.vm.provision :shell, :inline => "\
    echo '#{id_rsa_ssh_key_pub }' > /home/vagrant/.ssh/authorized_keys && chmod 600 /home/vagrant/.ssh/authorized_keys"

  # set defaults for VMs
  config.vm.provider 'virtualbox' do |vb|
    vb.customize ["modifyvm", :id, "--cpus", 1]
    vb.customize ["modifyvm", :id, "--memory", 512]
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
    vb.customize ['modifyvm', :id, "--natdnshostresolver1", "off"]

    # solve issue 'stuck connection timeout retrying'
    # centos shows kernel selection menu
    # https://stackoverflow.com/questions/22575261/vagrant-stuck-connection-timeout-retrying
    # vb.gui = true
    # reduce first-time boot long waiting (600 sec default timeout)
    config.vm.boot_timeout = 120
  end

  config.vm.define 'vmbox1' do |vmbox|
    vmbox.vm.hostname = "vmbox1"
    vmbox.vm.network "private_network", ip: "192.168.10.101"

    # increase memory (for gitlab nodejs, ruby)
    vmbox.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 2048]
    end
  end

  config.vm.define 'vmbox2' do |vmbox|
    vmbox.vm.hostname = "vmbox2"
    vmbox.vm.network "private_network", ip: "192.168.10.102"
  end
end
