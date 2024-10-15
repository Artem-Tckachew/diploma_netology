resource "yandex_compute_disk" "disk-webserv-1" {
  name     = "disk-webserv1"
  type     = "network-hdd"
  zone     = var.zone_a
  image_id = var.image_id
  size     = 10

}

resource "yandex_compute_disk" "disk-webserv-2" {
  name     = "disk-webserv2"
  type     = "network-hdd"
  zone     = var.zone_b
  image_id = var.image_id
  size     = 10

}

resource "yandex_compute_disk" "disk-bastionserv" {
  name     = "disk-bastionserv"
  type     = "network-hdd"
  zone     = var.zone_d
  image_id = var.image_id
  size     = 10

}

resource "yandex_compute_disk" "disk-zabbixserv" {
name     = "disk-zabbixserv"
  type     = "network-hdd"
  zone     = var.zone_d
  image_id = var.image_id
  size     = 10

}

resource "yandex_compute_disk" "disk-elasticserv" {
  name     = "disk-elasticserv"
  type     = "network-hdd"
  zone     = var.zone_d
  image_id = var.image_id
  size     = 20

}

resource "yandex_compute_disk" "disk-kibanaserv" {
  name     = "disk-kibanaserv"
  type     = "network-hdd"
  zone     = var.zone_b
  image_id = var.image_id
  size     = 10

}
