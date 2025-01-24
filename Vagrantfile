# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

vms = {
  'ldap-master1' => {'memory' => '1536', 'cpus' => 1, 'ip' => '201', 'box' => 'rocky-linux9-vagrant/rocky-linux9-vagrant', 'provision' => 'provision/ansible/ldap-master1.yaml'},
  'ldap-master2' => {'memory' => '1536', 'cpus' => 1, 'ip' => '202', 'box' => 'rocky-linux9-vagrant/rocky-linux9-vagrant', 'provision' => 'provision/ansible/ldap-master2.yaml'},
  'linux-services' => {'memory' => '2048', 'cpus' => 1, 'ip' => '203', 'box' => 'rocky-linux9-vagrant/rocky-linux9-vagrant', 'provision' => 'provision/ansible/linux-services.yaml'},
  'ad-server' => {'memory' => '1536', 'cpus' => 1, 'ip' => '204', 'box' => 'samba4-rocky-linux9-vagrant/samba4-rocky-linux9-vagrant', 'provision' => 'provision/ansible/ad-server.yaml'},
  'linux-client' => {'memory' => '1024', 'cpus' => 1, 'ip' => '205', 'box' => 'rocky-linux9-vagrant/rocky-linux9-vagrant', 'provision' => 'provision/ansible/linux-client.yaml'}
}

Vagrant.configure('2') do |config|
  config.vm.box_check_update = false
  
  vms.each do |name, conf|
    config.vm.define "#{name}" do |k|
      k.vm.box = "#{conf['box']}"
      k.vm.hostname = "#{name}"
      k.vm.network 'private_network', ip: "172.16.0.#{conf['ip']}"
      
      k.vm.provider 'virtualbox' do |vb|
        vb.name = "#{name}"
        vb.memory = conf['memory']
        vb.cpus = conf['cpus']
      end
      k.vm.provision 'ansible_local' do |ansible|
        ansible.install = false
        ansible.playbook = "#{conf['provision']}"
        ansible.compatibility_mode = '2.0'
      end
    end
  end

  config.vm.define "windows-client" do |win11|
    win11.vm.box = "windows11-client/windows11-client"
    win11.vm.network 'private_network', ip: "172.16.0.206"
    win11.vm.box_version = "1.0.0"
    win11.vm.guest = :windows
    
    win11.vm.provider 'virtualbox' do |vb|
      vb.name = "windows-client"
      vb.memory = "2048"
      vb.cpus = 2
      vb.gui = true
    end
  end
end

