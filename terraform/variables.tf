variable "autch_token" {
  description = "Введите секретный токен от yandex_cloud"
  type    = string
  // Прячет значение из всех выводов
  // По умолчанию false
  sensitive = true
}
variable "cloud_id" {
  type    = string
  default = "b1gdp19eftkho5bt5isl"
}

variable "folder_id" {
  type    = string
  default = "b1g11stnhjcsvm2rbbnq"
}

variable "image_id" {
  type    = string
  default = "fd8a57cqgaima6ke454e"
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

variable "zone_d" {
  description = "zone"
  type    = string
  default = "ru-central1-d"
}

