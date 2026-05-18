Vagrant.configure("2") do |config|
    config.vm.box = "debian/trixie64"
  
    config.vm.provider :libvirt do |libvirt|
        libvirt.driver = "kvm"

    end

    config.vm.provision "shell", inline: <<-SHELL
        echo "Hello, World!"
    SHELL
end
