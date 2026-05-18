Vagrant.configure("2") do |config|
    config.vm.box = "debian/trixie64"

    config.vm.define "pouetS" do |control| 
        control.vm.hostname = "pouetS"
        control.vm.network "private_network", ip: "192.168.56.110"
        control.vm.provider "libvirt" do |libvirt|
            libvirt.memory = 512
            libvirt.cpus = 1
        end
        control.vm.provision "shell", inline: <<-SHELL
            echo pouetS
        SHELL
    end

    config.vm.define "pouetSW" do |control| 
        control.vm.hostname = "pouetSW"
        control.vm.network "private_network", ip: "192.168.56.111"
        control.vm.provider "libvirt" do |libvirt|
            libvirt.memory = 512
            libvirt.cpus = 1
        end
        control.vm.provision "shell", inline: <<-SHELL
            echo pouetSW
        SHELL
    end

end
