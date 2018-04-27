# -*- mode: ruby -*-
# vi: set ft=ruby :

# Settings for the Virtualbox VM
VM_MEMORY = "4096"
VM_CPUS = "2"
VM_NAME = "DEV VM"
VM_IP   = "10.10.0.100"
HOSTNAME = "#{ENV['USER'] || ENV['USERNAME']}-dev"

if Vagrant::Util::Platform.windows?
  SYNCED_FOLDER_TYPE = ''
else
  SYNCED_FOLDER_TYPE = 'nfs'
end

Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/trusty64"

	config.vm.network "private_network", ip: VM_IP # NFS benötigt ein privates Netzwerk
	config.vm.network "public_network"
	config.vm.network "forwarded_port", guest: 3306, host: 3306
	config.vm.hostname = HOSTNAME

	config.vm.synced_folder "./www/", "/var/www/html", type: SYNCED_FOLDER_TYPE
	if SYNCED_FOLDER_TYPE == "nfs"
		config.nfs.map_uid = Process.uid
		config.nfs.map_gid = Process.gid
	end

	# disable auto updates by vbguest plugin
	if Vagrant.has_plugin? 'vagrant-vbguest'
		config.vbguest.auto_update = false
		config.vbguest.no_remote = true
		config.vbguest.no_install = true
	end

	# add hosts to /etc/hosts
    if Vagrant.has_plugin? 'vagrant-hostmanager'
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true
        config.hostmanager.aliases = HOSTNAME
    else
        raise "ERROR: vagrant-hostmanager plugin not installed.\nInstall it using 'vagrant plugin install vagrant-hostmanager'\n\n\033[0m"
    end

	config.vm.provider "virtualbox" do |vb|
		vb.name = VM_NAME
		vb.customize([
			"modifyvm", :id,
			"--memory", VM_MEMORY,
			"--cpus", VM_CPUS,
		])
	end

	config.vm.provision "shell",
		:path => "vagrant/provision.sh",
		:keep_color => true,
		:privileged => false
end
