variable "autch_token" {
  description = "Введите секретный токен от yandex_cloud"
  type    = string
  // Прячет значение из всех выводов
  // По умолчанию false
  sensitive = true
}
variable "cloud_id" {
  type    = string
  default = "b1gsrmo58qhsceb6on50"
}

variable "folder_id" {
  type    = string
  default = "b1grb8nkkkiergntbbde"
}

variable "image_id" {
  type    = string
  default = "fd8cg4hn26sqsbj8p4mj"
}

variable "zone_a" {
  description = "zone"
  type    = string
  default = "ru-central1-a"
}

variable "zone_b" {
  description = "zone"
  type    = string
  default = "ru-central1-b"
}
