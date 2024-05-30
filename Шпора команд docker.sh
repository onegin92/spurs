# Introduction to Docker by Denis Astahov
https://github.com/adv4000/docker

Install Docker on Ubuntu 18.04
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```
sudo apt update
sudo apt install apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce
sudo systemctl status docker
sudo usermod -aG docker $USER
>>>logout/login<<<
```


docker ps # посмотреть запущенные контейнеры
docker ps -a # посмотреть все запущенные контейнеры

docker images # посмотреть все images
docker search tomcat # поиск образа в dockerhub
docker pull tomcat # загрузка образа

docker run -it -p 1234:8080 tomcat # запуск образа в интерактивном режиме с перенаправлением портов
docker run -it -p 8888:80 nginx # запуск образа в интерактивном режиме с перенаправлением портов
docker run -d -p 8888:80 nginx # запуск образа как демон с перенаправлением портов
docker run --name <example> -d <image> # создать контейнер с именем example на основе образа image
docker run nginx sleep 5 # передать в контейнер команду, наприме работать 5 секунд
docker run --rm --name <example> -d <image> # rm удаляет контейнер при его остановке

docker build -t peklich:v1 . # Делаем image из Dockerfile, (. это здесь, v1 - TAG, peklich - имя)

docker tag denis_ubuntu peklich-PROD # создаем копию image
docker tag denis_ubuntu peklich-PROD:v2 # создаем копию image с изменением TAG

docker rm   # delete container (-f позволяет удалять запущенные контейнеры без их предварительной остановки)
docker rmi  # delete image
docker rm -f $(docker ps -aq)        # Delete all Containers
docker rmi -f $(docker images -q)    # Delete all Images

docker container start example # Запустить созданный контейнер в фоновом режиме
docker container stop <имя_или_id> # Остановить созданный контейнер

docker logs -f elastalert # Просмотр логов контейнера

docker inspect <id> # посмотреть с какими параметрами был запущен контейнер
docker stats <id> # посмотреть потребление ресурсов 

dpcker volume ls # посмотреть все volume, хранятся в /var/lib/docker/volumes
docker volume create peklichea # создать volume
docker volume rm peklichea # удалить volume

docker network ls # просмотр сетей docker
# сети по умолчанию:
# bridge - 172.17.0.0/16, в ней конейнеры не могут общаться по dns именам
# host - ip сервера
# none - без ip адреса 
# контейнеры из разных сетей изолированы друг от друга, так как и контейнеры без сети(None)
docker network create --drive bridge NAME # создать сеть типа bridge(она по умолчанию, поэтому можно не указывать), в это сети контейнеры могут обаться по dns именам
docker run --net NAME nginx # запустить контейнер в сети NAME
docker network inspect NAME # посмтреть информацию о сети NAME
docker network create -d bridge --subnet 192.168.10.0/24 --gateway 192.168.10.1 myNet192 # создать сеть с нужно нумерацией
docker network rm myNet192 # удалить сеть
docker network connect myNet192 container1 # подключить контейнер к еще одной сети
docker network disconnect <id_network> container1 # удалить сеть с контейнера, id взять из docker inspect container1
# macvlan - каждый контейре со своим маком
# ipvlan - каждый контейнер с маком хоста
docker network create -d macvlan --subnet 192.168.100.0/24 --gateway 192.168.100.1 --ip-range 192.168.100.99/32 -o perent=ens18 myMACvlan # создаем macvlan сеть с пулом ip-range
# или
docker run --rm -it --name container1 --ip 10.10.10.213 --net macvlan nginx /bit/bash # создать контейнер и назначить ему ip

UPDATE IMAGE
~~~~~~~~~~~~~
docker run -d -p 7777:80 denis_ubuntu4 # Создать контейнер
docker exec -it 5267e21d140 /bin/bash # Зайти внутрь контейнера
evn # если ввести внутри контейнера, то покажет все переменные
echo "V2" >> /var/www/html/index.html # Меняем файл 
exit # Выход из контейнера
docker commit 5267e21d140 denis_v2:latest # Создаем новый image



Export/Import Docker Image to file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker save image:tag > arch_name.tar
docker load -i arch_name.tar

Import/Export Docker Image to AWS ECR
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker build -t denis:v1 .
aws ecr get-login --no-include-email --region=ca-central-1 
docker tag  denis:v1  12345678.dkr.ecr.ca-central-1.amazonaws.com/myrepo:latest
docker push 12345678.dkr.ecr.ca-central-1.amazonaws.com/myrepo:lastest
docker pull 12345678.dkr.ecr.ca-central-1.amazonaws.com/myrepo:latest

Монтирование папки к контейнеру:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
docker run --net=bridge -d --name elastalert --restart=always \
-v $(pwd)/elastalert.yaml:/opt/elastalert/config.yaml \
-v $(pwd)/rules:/opt/elastalert/rules \
jertel/elastalert2 --verbose





~~~~~~~~~~~~~~~~~~ пример файла Dockerfile ~~~~~~~~~~~~~~~~~~
FROM ubuntu:16.04 # базовый образ
LABEL autor=Peklichea # Описание образа
# команды 
RUN apt-get -y update
RUN apt-get -y install apache2
RUN echo 'Hello World' > /var/www/html/index.html
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"] # запускаем как демон
EXPOSE 80 # открываем порт 80, информационная команда
WORKDIR /var/www/html/ # рабочая директория
COPY files2/index.html . # копируем файлы с локальной машины в рабочую директорию
COPY files2/script.sh /opt/script.sh # копируем файлы с локальной машины в папку
RUN chmod +x /opt/script.sh # работа с файлами
ENV OWNER="Peklichea" # пишим переменную
ENV TYPE=demo # пиши м переменную
ENTRYPOINT ["echo"] # описание команд при запуске контейнера 
CMD ["Hello my FIRST Docker"] # описание команд при запуске контейнера
~~~~~~~~~~~~~~~~~~ пример файла Dockerfile ~~~~~~~~~~~~~~~~~~
docker build . # создаем образ
docker tag <id созданного образа> myimage:v01 # меняем имя и TAG
docker image inspect <имя или id> # просмотреть всю информацию об образе
docker build -t myimage:v01 . # создаем образ с именем и тегом
docker run --rm --name <example> -P -d myimage:v01 # запускаем контейнер с прокидывание рандомного порта на EXPOSE

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ docker-compose ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

docker-compose up # запуск compose
#или в новых версиях 
docker compose up # запуск compose
-d # запустить в фонов режиме

docker-compose ps # запущенные контейнеры compose

docker-compose logs -f # просмотр логов 

docker-compose stop # остановить все контейнеры, без удаления

~~~~~~~~~~~~~~~~ пример файла docker-compese.yml ~~~~~~~~~~~~~~~~~~
version: "3.5" # версия по кторой будет работать docker-compose
services: #описание всех контейнеров которые будем запускать
    web-server-prod: # можно указать любое имя
        image: nginx:stable # указываем какой образ испольовать
        # build: . # если хотим использовать Dockerfile вместо готового image, тогда строку выше надо закомментить
        container_name: mynginx-prod # имя созданного контенйра, параметр не обязательный
        # command: --transaction-isolarion=READ-COMMITTED --binlog-format=ROW # команда, которая будет запущена при запуске контейнера ???????????????
        volumes: # указываем то что было перечислено в docker run -v
            - "/opt/web/html:/var/www/html" # создается если папки нет и мапится в контейнер
            - "/opt/web/pics:/var/www/pictures" # создается если папки нет и мапится в контейнер
            - "nginx-config:/var/www/config" # именное volume, ниже нужно описать, создается только в контейнере ???????????????
        environment: # указываем то что было перечислено в docker run -e
            - NGINX_HOST=web.romnero.de
            - NGINX_PORT=80
        ports: # указываем то что было перечислено в docker run -p
            -"80:80"
            -"443:443"
        restart: unless-stopped # always/no/on-faillure указывает что делать с контейнером при его остановке, перезагрузке сервера и т.д.
        depends_on: # указываем после каких services запускать контейнер
            - web-server-test
        networks:
            - public

    web-server-test: # можно указать любое имя
        image: nginx:stable # указываем какой образ испольовать
        container_name: mynginx-test # имя созданного контенйра, параметр не обязательный
        volumes: # указываем то что было перечислено в docker run -v
            - "/opt/web/html:/var/www/html" # создается если папки нет и мапится в контейнер
            - "/opt/web/pics:/var/www/pictures" # создается если папки нет и мапится в контейнер
            - "nginx-config:/var/www/config" # именно volume, ниже нужно описать, создается только в контейнере
        environment: # указываем то что было перечислено в docker run -e
            - NGINX_HOST=web.romnero.de
            - NGINX_PORT=80
        ports: # указываем то что было перечислено в docker run -p
            -"80:80"
            -"443:443"
        restart: unless-stopped # always/no/on-faillure указывает что делать с контейнером при его остановке, перезагрузке сервера и т.д.
        networks:
            - private

volumes:
    nginx-config:

networks:
    default:
        driver: bridge
        name: webnet
    public:
        driver: bridge
        name: public
    private:
        driver: bridge
        name: private
~~~~~~~~~~~~~~~~ пример файла docker-compese.yml ~~~~~~~~~~~~~~~~~~



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Portainer ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

###### Установка
cat /etc/os-release # проверить OS
sudo su 
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
docker --version
docker compose version
# создаем docker compose файл
nano docker-compose.yml

version: "3.3"
services:
    portainer:
        inage: portainer/poertainer-ce:latest
        container_name: portainer
        environment:
            - TZ=Europe/Berlin
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - /opt/portainer/portainer_data:/data
        ports:
            - "8000:8000"
            - "9443:9443"
        restart: always

docker compose up -d
docker ps 

# переходим в web



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Watchtower ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
https://containrrr.dev/watchtower/

# Обновление образов вручную
# удаляем старый контейнер
docker tag garafana/grafana:9.2.8 grafana/grafana:latest # меняем TAG
docker run -d --name=grafana -p 3000:3000 grafana/grafana # создаем контейнер
docker pull grafana/grafana:latest
docker stop grafana
docker rm grafana 
docker run -d --name=grafana -p 3000:3000 grafana/grafana # создаем контейнер

# Обновление контейнеров с помощью Watchtower, проверка 1 раз в 24 часа, запустится через 24 часа
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower

# Обновление контейнеров с помощью Watchtower, запустить одни раз прямо сейчас
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower \
--run-once

# Обновление нужных контейнеров с помощью Watchtower, запустить одни раз прямо сейчас
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower \
--run-once nginx01 nginx02

# Обновление контейнеров с помощью Watchtower, по расписанию
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
containrrr/watchtower \
--schedule "0 0 4 * * *" # секунды, минуты, часы, день месяца, месяц, день недели

--monitor-only # не обновлять, а только уведомить

# так же можно сделать исключения, см видео https://youtu.be/L63s3IMbmo0?list=PLqVeG_R3qMSwjnkMUns_Yc4zF_PtUZmB-&t=1025
# с помощью Gotify можно настроить уведомления об обновлениях


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Traefik V2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Traefik V2. Reverse Proxy и LoadBalancer для контейнеров в динамическом окружении.




~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Docker Swarm ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# устанавливаем multipass и поднимаем машинки
multipass list
multipass launch --name swarm-master
multipass launch --name swarm-worker1
multipass launch --name swarm-worker2
multipass list
multipass shell swarm-master # заходим на master
# устанавливаем docker на каждую машинку по инструкции https://docs.docker.com/engine/install/ubuntu/

docker swarm init # инициализируем swarm на мастере
docker service ls # проверяем ????
docker node ls # смотрим список доступных нод

git clone --depth 1 --branch 0.2 https://github.com/shadrus/swarmlesssonapi.git 
docker stack deploy -c docker-stack.yml api # делаем депрой проекта из docker-stack.yml, сервис называется api
docker service ps <ID сервиса> # смотрем где запущен сервис
docker service scale <ID сервиса>=2 # запустить 2 копии сервиса

http://192.168.1.164:8090/version # смотрим в web


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Swarmpit ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

git clone https://github.com/shadrus/swarmpit.git # выполняем на мастере

docker node update --label-add db=true sworm-worker2 # обновить информацию о ноде
docker node inspect sworm-worker2 # посмтреть всю инфу по ноде
docker stack deploy -c docker-stack.yml swarm # делаем депрой проекта из docker-stack.yml, сервис называется swarm
docker service ls # проверяем сервисы

# Переменные окружения, секреты, конфигурации
printf varysecrettoken | sudo docker secret create swarm-lessons-token - # создаем secret
docker stack deploy -c docker-stack.yml api # повторно деплоим

# просмотр секретов
# заходим на ноду где развернут сервис
docker ps
docker exec -it 5528f1aeb070 sh
cd /run/secrets/
cat swarm-lessons-token


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ registry ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




