# -*- mode: ruby -*-
# vi: set ft=ruby :
# // To list interfaces on CLI typically:
# //    macOS: networksetup -listallhardwareports ;
# //    Linux: lshw -class network ;
#sNET='en0: Wi-Fi (Wireless)'  # // network adaptor to use for bridged mode
sNET='en7: USB 10/100/1000 LAN'  # // network adaptor to use for bridged mode
VV1=''  # ='1.7.3+ent.hsm'  # VV1='' to Install Latest OSS
VPLUGIN_INSTANCES='96'
IPDB='192.168.178.50'
IPV='192.168.178.51'

sVUSER='vagrant'  # // vagrant user
sHOME="/home/#{sVUSER}"  # // home path for vagrant user
aCLUSTERA_FILES =  # // Vault files to copy to instances
[
	"vault_files/."  # "vault_files/vault_seal.hcl", "vault_files/vault_license.txt"  ## // for individual files
];

Vagrant.configure("2") do |config|
	config.vm.box_url = "https://oracle.github.io/vagrant-projects/boxes/oraclelinux/7.json"
	config.vm.box = "oraclelinux/7"

	config.vm.define "db" do |db|
		db.vm.hostname = "db"
		db.vm.network "public_network", bridge: "#{sNET}", ip: "#{IPDB}"
		db.vm.provider "virtualbox" do |v|
			v.memory = 3072
			v.cpus = 2
		end
		db.vm.provision "shell", inline: "/bin/bash -c 'yum install -y -q htop glances'"
		db.vm.provision "flashback", type: "shell", path: "cc.os.user-input/oracle_db/1.flashback.sh", run: "never"
		db.vm.provision "shell", path: "cc.os.user-input/oracle_db/2.provision_db.sh", env: {"IPV" => "#{IPV}", "IPDB" => "#{IPDB}" }
		db.vm.provision "shell", path: "cc.os.user-input/oracle_db/3.create_db.sh", run: "always"
	end

	config.vm.define "vault1" do |vault|
		vault.vm.hostname = "vault1"
		vault.vm.network "public_network", bridge: "#{sNET}", ip: "#{IPV}"
		vault.vm.provider "virtualbox" do |v2|
			v2.memory = 4096
			v2.cpus = 4
		end

		# // where additional Vault related files exist copy them across (eg License & seal configuration)
		for sFILE in aCLUSTERA_FILES
			if(File.file?("#{sFILE}") || File.directory?("#{sFILE}"))
				vault.vm.provision "file", source: "#{sFILE}", destination: "#{sHOME}"
			end
		end

		vault.vm.provision "shell", path: "cc.os.user-input/vault/1.install_commons.sh", env: {"IPV" => "#{IPV}", "IPDB" => "#{IPDB}" }
		vault.vm.provision "shell", path: "cc.os.user-input/vault/2.provision_instantclient.sh"
		vault.vm.provision "shell", path: "cc.os.user-input/vault/3.install_vault.sh", env: {"VAULT_VERSION" => "#{VV1}", "VAULT_CLUSTER_NAME" => "oracle_db_testing", "HOME_PATH" => "#{sHOME}", "USER" => "#{sVUSER}" }
		vault.vm.provision "shell", path: "cc.os.user-input/vault/4.vault_configure_dynamic.sh", env: {"VPLUGIN_INSTANCES" => "#{VPLUGIN_INSTANCES}"}
		vault.vm.provision "file", source: "vault_files/vault_oracledb_test.sh", destination: "#{sHOME}/vault_oracledb_test.sh"
	end

end
