Dependências
------------

Para a criação do laboratório é necessário ter pré instalado os seguintes softwares:

* [Git]
* [VirtualBox]
* [Vagrant]

> Para rovisionamento estamos utilizando Shell Script

Para criar o laboratório é necessário fazer o `git clone` desse repositório e, dentro da pasta baixada realizar a execução do `vagrant up`, conforme abaixo:

```bash
git clone https://github.com/alissonoliveira0607/Devops-PostgreSQL-Provisioner.git
cd Devops-PostgreSQL-Provisioner/
vagrant up
```

Comandos                | Descrição
:----------------------:| ---------------------------------------
`vagrant init`          | Gera o VagrantFile
`vagrant box add <box>` | Baixar imagem do sistema
`vagrant box status`    | Verificar o status dos boxes criados
`vagrant up`            | Cria/Liga as VMs baseado no VagrantFile
`vagrant provision`     | Provisiona mudanças logicas nas VMs
`vagrant status`        | Verifica se VM estão ativas ou não.
`vagrant ssh <vm>`      | Acessa a VM
`vagrant ssh <vm> -c <comando>` | Executa comando via ssh
`vagrant reload <vm>`   | Reinicia a VM
`vagrant halt`          | Desliga as VMs

> Para maiores informações acesse a [Documentação do Vagrant][https://www.vagrantup.com/docs]



=======================

    Alisson Oliveira

=======================