output "bastion-host" {
  value = yandex_compute_instance.bastionserv.network_interface.0.nat_ip_address
}
output "kibana" {
  value = yandex_compute_instance.kibanaserv.network_interface.0.nat_ip_address
}
output "zabbix" {
  value = yandex_compute_instance.zabbixserv.network_interface.0.nat_ip_address
}
output "FQDN_bastion" {
  value = yandex_compute_instance.bastionserv.fqdn
}
output "FQDN_zabbix" {
  value = yandex_compute_instance.zabbixserv.fqdn
}
output "FQDN_elastic" {
  value = yandex_compute_instance.elasticserv.fqdn
}
output "FQDN_kibana" {
  value = yandex_compute_instance.kibanaserv.fqdn
}
output "FQDN_webserv-1" {
  value = yandex_compute_instance.webserv-1.fqdn
}
output "FQDN_webserv-2" {
  value = yandex_compute_instance.webserv-2.fqdn
}
