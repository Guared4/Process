# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version = "202407.23.0"
  config.vm.network "private_network", ip: "192.168.126.44"
  # Shared folder
  config.vm.synced_folder "./", "/vagrant"
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo cp /vagrant/ps_ax.sh /root
    sudo chmod +x /root/ps_ax.sh
    sudo bash /root/ps_ax.sh
    sudo cp /vagrant/lsof.sh /root
    sudo chmod +x /root/lsof.sh
    sudo cp /vagrant/CPU_nice.sh /root
    sudo chmod +x CPU_nice.sh
    SHELL
end
