output "external_ip_address_bastionserv" {
  value = yandex_compute_instance.bastionserv.network_interface.0.nat_ip_address
}

output "internal_ip_address_bastionserv" {
  value = yandex_compute_instance.bastionserv.network_interface.0.ip_address
}

output "FQDN_bastionserv" {
  value = yandex_compute_instance.bastionserv.fqdn
}

output "external_ip_address_zabbixserv" {
  value = yandex_compute_instance.zabbixserv.network_interface.0.nat_ip_address
}

output "internal_ip_address_zabbixserv" {
  value = yandex_compute_instance.zabbixserv.network_interface.0.ip_address
}

output "FQDN_zabbixserv" {
  value = yandex_compute_instance.zabbixserv.fqdn
}

output "external_ip_address_kibanaserv" {
  value = yandex_compute_instance.kibanaserv.network_interface.0.nat_ip_address
}

output "internal_ip_address_kibanaserv" {
  value = yandex_compute_instance.kibanaserv.network_interface.0.ip_address
}

output "FQDN_kibanaserv" {
  value = yandex_compute_instance.kibanaserv.fqdn
}

output "internal_ip_address_elasticserv" {
  value = yandex_compute_instance.elasticserv.network_interface.0.ip_address
}

output "FQDN_elastic" {
  value = yandex_compute_instance.elasticserv.fqdn
}

output "internal_ip_address_webserv-1" {
  value = yandex_compute_instance.webserv-1.network_interface.0.ip_address
}

output "FQDN_webserv-1" {
  value = yandex_compute_instance.webserv-1.fqdn
}

output "internal_ip_address_webserv-2" {
  value = yandex_compute_instance.webserv-2.network_interface.0.ip_address
}

output "FQDN_webserv-2" {
  value = yandex_compute_instance.webserv-2.fqdn
}

output "external_ip_address_L7balancer" {
  value = yandex_alb_load_balancer.l7b.listener.0.endpoint.0.address.0.external_ipv4_address
}
