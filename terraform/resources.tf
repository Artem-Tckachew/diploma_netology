#----------------- WEB -----------------------------
resource "yandex_compute_instance" "webserv-1" {
  name                      = "webserv-1"
  hostname                  = "webserv-1"
  zone                      = var.zone_a
  allow_stopping_for_update = true
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-webserv-1.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
    ip_address = "192.168.1.11"
    security_group_ids = [yandex_vpc_security_group.security-ssh-traffic.id, yandex_vpc_security_group.nginx-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "webserv-2" {
  name                      = "webserv-2"
  hostname                  = "webserv-2"
  zone                      = var.zone_b
  allow_stopping_for_update = true
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-webserv-2.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = false
    ip_address = "192.168.2.22"
    security_group_ids = [yandex_vpc_security_group.security-ssh-traffic.id, yandex_vpc_security_group.nginx-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#----------------- bastion -----------------------------
resource "yandex_compute_instance" "bastionserv" {
  name                      = "bastionserv"
  hostname                  = "bastionserv"
  zone                      = var.zone_d
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-bastionserv.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-4.id
    nat       = true
    ip_address = "192.168.4.55"
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}


#----------------- zabbix -----------------------------
resource "yandex_compute_instance" "zabbixserv" {
  name                      = "zabbixserv"
  hostname                  = "zabbixserv"
  zone                      = var.zone_d
  allow_stopping_for_update = true
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-zabbixserv.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-4.id
    nat       = true
    ip_address = "192.168.4.33"
    security_group_ids = [yandex_vpc_security_group.security-ssh-traffic.id, yandex_vpc_security_group.zabbix-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#----------------- elastic -----------------------------
resource "yandex_compute_instance" "elasticserv" {
  name                      = "elasticserv"
  hostname                  = "elasticserv"
  zone                      = var.zone_d
  allow_stopping_for_update = true
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-elasticserv.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-4.id
    nat       = false
    ip_address = "192.168.4.44"
    security_group_ids = [yandex_vpc_security_group.security-ssh-traffic.id, yandex_vpc_security_group.elastic-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#----------------- kibana -----------------------------
resource "yandex_compute_instance" "kibanaserv" {
  name                      = "kibanaserv"
  hostname                  = "kibanaserv"
  zone                      = var.zone_b
  allow_stopping_for_update = true
  platform_id               = "standard-v3"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk-kibanaserv.id}"
    }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
    ip_address = "192.168.2.32"
    security_group_ids = [yandex_vpc_security_group.security-ssh-traffic.id, yandex_vpc_security_group.kibana-sg.id]
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
