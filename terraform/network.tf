//__________________________СЕТЬ_______________________________________
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

//_________________________ПОДСЕТЬ-1____________________________________
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
  route_table_id = yandex_vpc_route_table.nginx1-2_elastic.id
}

//_________________________ПОДСЕТЬ-2____________________________________
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.nginx1-2_elastic.id
}

//_________________________ПОДСЕТЬ-4____________________________________
resource "yandex_vpc_subnet" "subnet-4" {
  name           = "subnet4"
  zone           = var.zone_d
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.4.0/24"]
  route_table_id = yandex_vpc_route_table.nginx1-2_elastic.id
}

#----------------------------- HTTP router ----------------------------------

resource "yandex_alb_http_router" "nginx-router" {
  name      = "nginx-router"
}

//______________________ВИРТУАЛЬНЫЙ__ХОСТ____________________________________
resource "yandex_alb_virtual_host" "ngx-virtual-host" {
  name                    = "ngx-virtual-host"
  http_router_id          = yandex_alb_http_router.nginx-router.id
  route {
    name                  = "ngx-route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.nginx-backend-group.id
      }
    }
  }
}    

#------------------------------ L7 balancer -------------------------------

resource "yandex_alb_load_balancer" "nginx-balancer" {
name        = "nginx-balancer"
  network_id  = yandex_vpc_network.network-1.id

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.subnet-1.id 
    }
    location {
      zone_id   = var.zone_b
      subnet_id = yandex_vpc_subnet.subnet-2.id 
    }
   
    location {
      zone_id   = var.zone_d
      subnet_id = yandex_vpc_subnet.subnet-4.id 
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.nginx-router.id
      }
    }
  }
}

//_________________________TARGET_GROUP___________________________________________
resource "yandex_alb_target_group" "ngx-target-group" {
  name      = "ngx-target-group"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address   = "${yandex_compute_instance.webserv-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address   = "${yandex_compute_instance.webserv-2.network_interface.0.ip_address}"
  }
}

//______________________BACKEND_GROUP__________________________________________________
resource "yandex_alb_backend_group" "nginx-backend-group" {
  name      = "nginx-backend-group"

  http_backend {
    name = "backend-1"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.ngx-target-group.id]
    
    load_balancing_config {
      panic_threshold = 0
    }    
    healthcheck {
      timeout = "1s"
      interval = "3s"
      healthy_threshold    = 2
      unhealthy_threshold  = 2 
      healthcheck_port     = 80
      http_healthcheck {
        path  = "/"
      }
    }
  }
}

#--------------------------security_group------------------------

# ----------------------Security Bastion Host--------------------

resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "access via ssh"
  network_id  = "${yandex_vpc_network.network-1.id}"  
  ingress {
      protocol          = "TCP"
      description       = "ssh-in"
      port              = 22
      v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      protocol          = "ANY"
      description       = "any for basion to out"
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

# ---------------------Security SSH Traffic----------------------

resource "yandex_vpc_security_group" "security-ssh-traffic" {
  name       = "security-ssh-traffic"
  network_id = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.4.0/24"]
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.4.0/24"]
  }
}

//_______________ШЛЮЗ И ТАБЛИЦА МАРШРУТИЗАЦИИ__________________________
resource "yandex_vpc_gateway" "nginx1-2_elastic_gateway" {
  name = "nginx-elastic-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nginx1-2_elastic" {
  name       = "nginx-elastic-route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nginx1-2_elastic_gateway.id
  }
}

# ---------------------Security WebServers-------------------------

resource "yandex_vpc_security_group" "nginx-sg" {
  name        = "nginx-sg"
  description = "rules for nginx"
  network_id  = "${yandex_vpc_network.network-1.id}"  

   ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.4.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix in"
    port           = 10050
    v4_cidr_blocks = ["192.168.4.0/24"] 
  }

  ingress {
    description = "Health checks from NLB"
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks" 
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# -------------------Security Public Kibana-----------------------

resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  description = "rules for kibana"
  network_id  = "${yandex_vpc_network.network-1.id}"  

  ingress {
    protocol       = "TCP"
    description    = "kibana interface"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix in"
    port           = 10050
    v4_cidr_blocks = ["192.168.4.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------Security Public Zabbix-----------------------

resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  description = "rules for zabbix"
  network_id  = "${yandex_vpc_network.network-1.id}"  

  ingress {
    protocol       = "TCP"
    description    = "HTTP in"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "zabbix in"
    port           = 10051
    v4_cidr_blocks = ["192.168.4.0/24"] 
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
# ---------------------Security ElasticSearch----------------------

resource "yandex_vpc_security_group" "elastic-sg" {
  name        = "elastic-sg"
  description = "rules for elastic"
  network_id  = "${yandex_vpc_network.network-1.id}"  

  ingress {
    protocol       = "TCP"
    description    = "zabbix in"
    port           = 10050
    v4_cidr_blocks = ["192.168.4.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "elastic agent in"
    port           = 9200
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.4.0/24"] 
  }

   egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}