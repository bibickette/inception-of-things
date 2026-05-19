Vagrant.configure("2") do |config|
    config.vm.box = "debian/trixie64"

    config.vm.define "pouetS", primary: true  do |control| 
        control.vm.hostname = "pouetS"
        control.vm.network "private_network", ip: "192.168.56.110"
        control.vm.provider "libvirt" do |libvirt|
            libvirt.memory = 1024
            libvirt.cpus = 1
        end
        control.vm.provision "shell", path: "script/server.sh"
    end

    config.vm.define "pouetSW", primary: false do |control| 
        control.vm.hostname = "pouetSW"
        control.vm.network "private_network", ip: "192.168.56.111"
        control.vm.provider "libvirt" do |libvirt|
            libvirt.memory = 512
            libvirt.cpus = 1
        end
        control.vm.provision "shell", path: "script/agent.sh"
    end

end
