resource "yandex_compute_snapshot_schedule" "default1" {
  name = "default1"
  description    = "Ежедневные снимки, хранятся 7 дней"
 
    schedule_policy {
    expression = "0 1 * * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "retention-snapshot"

  }

  disk_ids = [
    "${yandex_compute_disk.disk-webserv-1.id}",
    "${yandex_compute_disk.disk-webserv-2.id}",
    "${yandex_compute_disk.disk-bastionserv.id}",
    "${yandex_compute_disk.disk-zabbixserv.id}",
    "${yandex_compute_disk.disk-elasticserv.id}",
    "${yandex_compute_disk.disk-kibanaserv.id}",
  ]

  depends_on = [
     yandex_compute_instance.webserv-1,
     yandex_compute_instance.webserv-2,
     yandex_compute_instance.bastionserv,
     yandex_compute_instance.zabbixserv,
     yandex_compute_instance.elasticserv,
     yandex_compute_instance.kibanaserv
  ]

}
