# -*- mode: ruby -*-
# vi: set ft=ruby :
# // To list interfaces on CLI typically:
# //    macOS: networksetup -listallhardwareports ;
# //    Linux: lshw -class network ;
#sNET='en0: Wi-Fi (Wireless)'  # // network adaptor to use for bridged mode
sNET='enp2s0'  # // network adaptor to use for bridged mode
#VV1=''  # ='1.7.3+ent.hsm'  # VV1='' to Install Latest OSS
#VV1='1.16.0-rc2'  # VV1='' to Install Latest OSS
VV1='1.20.0+ent'  # VV1='' to Install Latest OSS
VPLUGIN_INSTANCES='1'
IPDB='192.168.168.50'
IPV='192.168.168.51'
IPV2='192.168.168.52'

sVUSER='vagrant'  # // vagrant user
sHOME="/home/#{sVUSER}"  # // home path for vagrant user
aCLUSTERA_FILES =  # // Vault files to copy to instances
[
	"vault_files/."  # "vault_files/vault_seal.hcl", "vault_files/vault_license.txt"  ## // for individual files
];

## Patch UI to hide certian detailed messages making Vagrant outputs more concise
class Vagrant::UI::Colored
        def say(type, message, opts={})
        aMSG_SKIP = [ 'Verifying vmnet devices', 'Configuring network adapters within', 'Preparing network adapters', 'Forwarding ports', 'Fixed port collision for 22', 'Running provisioner: file...', 'Running provisioner: shell...' ]
        if aMSG_SKIP.any? { |s| message.include? s } ; return ; end
                aMSG_EXCLUDE = [ 'Verifying vmnet devices', 'Preparing network adapters', 'Forwarding ports', '-- 22 =>', 'SSH address:', 'SSH username', 'SSH auth method:', 'Vagrant insecure key detected.', 'this with a newly generated keypair', 'Inserting generated public', 'Removing insecure key from', 'Key inserted!']
                # puts type," --- ",message
                if aMSG_EXCLUDE.any? { |s| message.include? s } ## puts type, " --- ", message
                        super(type, message, opts.merge(hide_detail: true))
                else
                        super(type, message, opts.merge(hide_detail: false))
                end
        end
end

Vagrant.configure("2") do |config|
	config.vm.box_url = "https://oracle.github.io/vagrant-projects/boxes/oraclelinux/7.json"
	config.vm.box = "oraclelinux/7"
	config.vm.box_check_update = false  # // disabled to reduce verbosity - better enable

	config.vm.define "db" do |db|
		db.vm.hostname = "db"
		db.vm.network "public_network", bridge: "#{sNET}", ip: "#{IPDB}"
		db.vm.provider "virtualbox" do |v|
			v.memory = 3072
			v.cpus = 4
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

	config.vm.define "vault2" do |vault|
		vault.vm.hostname = "vault2"
		vault.vm.network "public_network", bridge: "#{sNET}", ip: "#{IPV2}"
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

#		vault.vm.provision "file", source: "vault_init.json", destination: "#{sHOME}"
		vault.vm.provision "shell", path: "cc.os.user-input/vault/1.install_commons.sh", env: {"IPV" => "#{IPV2}", "IPDB" => "#{IPDB}" }
		vault.vm.provision "shell", path: "cc.os.user-input/vault/2.provision_instantclient.sh"
		vault.vm.provision "shell", path: "cc.os.user-input/vault/3.install_vault.sh", env: { "VAULT_RAFT_JOIN" => "http://#{IPV}:8200", "VAULT_VERSION" => "#{VV1}", "VAULT_CLUSTER_NAME" => "oracle_db_testing", "HOME_PATH" => "#{sHOME}", "USER" => "#{sVUSER}" }
#		vault.vm.provision "shell", path: "cc.os.user-input/vault/4.vault_configure_dynamic.sh", env: {"VPLUGIN_INSTANCES" => "#{VPLUGIN_INSTANCES}"}
#		vault.vm.provision "file", source: "vault_files/vault_oracledb_test.sh", destination: "#{sHOME}/vault_oracledb_test.sh"
	end

end
