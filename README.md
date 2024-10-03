# Дипломная работа по профессии «Системный администратор» - Ткачев Артём

---

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 

---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  - для этого достаточно при создании ВМ указать name=example, hostname=examle !! 

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

1. Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

2. Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

3. Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

4. Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через [NAT-шлюз](https://yandex.cloud/ru/docs/vpc/operations/create-nat-gateway).

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

---

## Выполнение

---------

## Terraform

---------

Поднимаем инфраструктуру в Yandex Cloud используя terraform

в целях безопасности указываем token id, cloud id, folder id, через задание переменных текущего сеанса в консоли подставляя свои id в команды

```
provider "yandex" {
  token     = var.autch_token #секретные данные должны быть в сохранности!! Никогда не выкладывайте токен в публичный доступ.
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone_a
}
```

далее проверяем правильность конфигурации командой terraform plan и запускаем процесс поднятия инфраструктуры одной командой terraform init&& terraform plan&& terraform apply -auto-approve. После выполнения получаем данные output, которые мы прописывали в файле outputs.tf

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/1.png)

После завершения работы terraform проверяем в web консоли Yandex Cloud созданную инфраструктуру. Сервера webserv-1 и webserv-2 созданы в разных зонах.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/2.png)

### Сеть

### VPC и subnet

создаем 1 VPC с публичными и внутренними подсетями и таблицей маршрутизации для доступа к интернету ВМ находящихся внутри сети за Бастионом который будет выступать в роли интернет-шлюза.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/3.png)

### Группы безопасности

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/4.png)

### SG_LB

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/5.png)

### SG_zabbix с открытым портом 8080 и 10051 для доступа с интернета к Fronted Zabbix и работы Zabbix agent

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/9.png)

### SG_kibana c открытым портом 5601 для доступа c интернета к Fronted Kibana и портом 10050 для работы Zabbix_agent

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/8.png)

### SG_bastion c открытием только 22 порта для работы SSH

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/7.png)

### SG security-ssh-traffic с открытием только 22 порта для развертывания инфраструктуры с удаленной машины

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/6.png)

### Load Balancer

### Создаем Application load balancer

для распределения трафика на веб-сервера созданные ранее. Указываем HTTP router, созданный ранее, задаем listener тип auto, порт 80.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/13.png)

### карта балансировки

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/14.png)

### Создаем HTTP router

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/12.png)

### Создаем Target Group

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/10.png)

### Создаем Backend Group

Настраиваем backends на target group, ранее созданную, healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/11.png)

### Резервное копирование

### snapshot

создаем в terraform блок с расписанием snapshots

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/15.png)

проверяем на следующий день, что снимки создались по расписанию

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/16.png)

---

## Ansible

--

Установка и настройка ansible
устанавливаем ansible на локальном хосте где работали с terraform и настраиваем его на работу через bastion

файл конфигурации

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/17.png)

файл inventory

создаем файл hosts.ini c использованием FQDN имен серверов вместо ip
(т.к. DNS имя для ВМ bastion не регистрировалось глобально, то я просто использовал iр для доступа из интернета)

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/18.png)

проверяем доступность ВМ используя модуль ping

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/19.png)

Я разбил Ansible на роли и запускал один плейбук сразу на установку всех ролей.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/20.png)

проверяем доступность сайта в браузере по публичному ip адресу Load Balancer

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/21.png)

делаем запрос curl -v 51.250.35.210:80

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/22.png)

проверяем работу Load Balancer в web консоли YC

видим что меняется ip backend, значит балансировщик работает.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/23.png)

Мониторинг
проверяем доступность frontend zabbix сервера, ставим хосты на мониторинг, настраиваем дашборды.

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/24.png)

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/25.png)

Логи

проверяем, что Kibana работает

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/26.png)

Также проверяем, что верно настроена связка filebeat-elastic-kibana и логи видны на вебинтерфейсе kibana

![alt text](https://github.com/Artem-Tckachew/diploma_netology/blob/main/src/27.png)

Инфраструктура готова к эксплуатации.

---
