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
    subnet_id          = yandex_vpc_subnet.subnet_webserv-1.id
	dns_record {
      fqdn = "web1.srv."
    ttl = 300
    }
    security_group_ids = [yandex_vpc_security_group.internal.id]
    ip_address         = "10.10.1.3"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
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
    subnet_id          = yandex_vpc_subnet.subnet_webserv-2.id
	dns_record {
      fqdn = "web2.srv."
    ttl = 300
    }
    security_group_ids = [yandex_vpc_security_group.internal.id]
    ip_address         = "10.10.2.3"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

#----------------- bastion -----------------------------
resource "yandex_compute_instance" "bastionserv" {
  name                      = "bastionserv"
  hostname                  = "bastionserv"
  zone                      = var.zone_b 
  allow_stopping_for_update = true
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
    subnet_id          = yandex_vpc_subnet.public.id
	dns_record {
      fqdn = "bastion.srv."
    ttl = 300
    }
    nat                = true
    security_group_ids = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.public-bastion.id]
    ip_address         = "10.10.4.4"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}


#----------------- zabbix -----------------------------
resource "yandex_compute_instance" "zabbixserv" {
  name                      = "zabbixserv"
  hostname                  = "zabbixserv"
  zone                      = var.zone_b
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
    subnet_id          = yandex_vpc_subnet.public.id
	dns_record {
      fqdn = "zabbix.srv."
    ttl = 300
    }
    nat                = true
    security_group_ids = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.public-zabbix.id]
    ip_address         = "10.10.4.5"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}

#----------------- elastic -----------------------------
resource "yandex_compute_instance" "elasticserv" {
  name                      = "elasticserv"
  hostname                  = "elasticserv"
  zone                      = var.zone_b
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
    subnet_id          = yandex_vpc_subnet.private.id
	dns_record {
      fqdn = "elastic.srv."
    ttl = 300
    }
    security_group_ids = [yandex_vpc_security_group.internal.id]
    ip_address         = "10.10.3.4"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
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
    subnet_id          = yandex_vpc_subnet.public.id
	dns_record {
      fqdn = "kibana.srv."
    ttl = 300
    }
    nat                = true
    security_group_ids = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.public-kibana.id]
    ip_address         = "10.10.4.3"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

  scheduling_policy {  
    preemptible = true
  }
}
