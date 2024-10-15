resource "local_file" "ansible-inventory" {
  content  = <<-EOT
    [bastionhost]
    ${yandex_compute_instance.bastionserv.network_interface.0.ip_address} public_ip=${yandex_compute_instance.bastionserv.network_interface.0.nat_ip_address} 

    [web]
    ${yandex_compute_instance.webserv-1.network_interface.0.ip_address}
    ${yandex_compute_instance.webserv-2.network_interface.0.ip_address}


    [elasticserv]
    ${yandex_compute_instance.elasticserv.network_interface.0.ip_address}

    [kibanaserv]
    ${yandex_compute_instance.kibanaserv.network_interface.0.ip_address} public_ip=${yandex_compute_instance.kibanaserv.network_interface.0.nat_ip_address} 

    [zabbixserv]
    ${yandex_compute_instance.zabbixserv.network_interface.0.ip_address}  public_ip=${yandex_compute_instance.zabbixserv.network_interface.0.nat_ip_address}
    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastionserv.network_interface.0.nat_ip_address}"'
    EOT
  filename = "/home/artem/ansible/inventory.ini"
}