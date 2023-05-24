Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.network "private_network", ip:"27.78.101.100"
    config.vm.hostname = "postgres"
    config.vm.network "forwarded_port", guest: 5432,host: 5432
    config.vm.provider :virtualbox do |v|
      v.name = "POSTGRES" 
    config.vm.provision "shell", path: "provisioner/provision_postgres.sh"
    end
  end
  