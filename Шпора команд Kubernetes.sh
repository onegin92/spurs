
Написан на Go
Предназначен для:
 - Автоматизации Развертывания приложений
 - Автоматизации Масштабирования приложений
 - Автоматизации Управления приложениями

Основной компонент K8s это Cluster
Вы создаете K8s Cluster состоящий из Nodes
Nodes существует двух типов
 1. Worker Node - сервер на котором запускаются и работают конейнеры
 2. Master Node - сервер который управляем Worker Nodes

Master Node - сервер на котором работают три главных процесса k8s
 - kebe-apiserver
 - kebe-controller-manager
 - kebe-scheduler
Worker Node - сервер на котором работают два главных процесса k8s
 - kubelet # общается с kebe-apiserver сервером, команды получает
 - kube-proxy # сетевой интерфейс каждого сервера

Почему Kubernetes?
 - Доступность контейнера через ip, порт Worker Node или DNS, так же K8s сделает Load Balancing
 - Можно приАттачить любой локальный диск, AWS, GCP или Azure к одному или нескольким контейнерам
 - Автоматическое обновление Image или откат
 - Можно задвать сколько CPU и RAM нужно каждой копии контейнера, потом k8s сам решает на каких Worker их запускать
 - Self-healing, мы указываем сколько копий контейнеров нам нужно, если что то с одной из них произошло, k8s проверяет и заменяет не работающие
 - k8s позвоняет хранить секреты
 - Все большоие и не очень Cloud провайдеры сделали поддержку k8s

Главные Объекты Kubernetes, из чего состоит K8s
0. Container # Не является объектом Kubernetes
1. Pod # Сосотоит из одного или нескольких конейнеров
2. Deployment # Состоит из одного или нескольких Pod (копий), нужен для Auto Scaling и для обновления контейнеров, держит минимальное кол-во Pods
3. Service # Дает нам доступ к Pod которые бегут в Deployment через ClusterIP, NodePort, LoadBalancer, ExternalName
4. Nodes # Сервера
5. Cluster
DeamonSets
StatefulSets
RepicaSets
Secrets
PV
SVC 
LoadBalancers
ConfigMaps
Vertical Pod Autoscaler
Horizontal Pod Autoscaler
etcd # хранилище ключ-значение, используемое для хранения состояния всего кластера Kubernetes
kube-scheduler # компонент управления, который отслеживает вновь созданные Pod без назначенного узла и выбирает для них узел для запуска
kube-controller-manager # компонент управления, запускающий процессы контроллера

kubectl version # Показать версию kubectl клиента и сервера
kubectl version --client # Показать версию kubectl клиента
kubectl get componentstatuses # Показать состояние K8s Cluster
kubectl cluster-info # Показать информацию о K8s Cluster
kubectl get nodes # Казать все серверы K8s Cluster

# работа с pods
kubectl get pods # посомтреть все pods
kubectl run hello --image=httpd:latest --port=80 # создать Pod
kubectl delete pods hello # удалить Pod
kubectl describe pods hello # рассписать подробнее об pods
kubectl exec hello sh # запустить команду на Pod
kubectl exec -it hello sh # запустить команду на Pod интерактивно
kubectl logs hello # посмотреть логи 
kubectl port-forward hello 7788:80 # пробросить порт интерактивно
kubectl get pods --namespace kube-system # проверка запущенных сужб k8s
kubectl apply -f pod-myweb1.yaml # запускаем создание Pods из файла

# работа с DEPLOYMENTS
kubectl create deploy adm-pea --image nginx:latest # создать deploy
kubectl scale deployment adm-pea --replicas 4 # сделать 4 реплики deploy
kubectl get deployments # просмотр всех deploy
kubectl get rs # просомтрет replica sets
kubectl delete pods adm-pea-758d5f8589-npxwb # удалить pod, но автоматом создаться новый
kubectl autoscale deployment adm-pea --min=4 --max=6 --cpu-percent=80 # создать horizontalpodautoscaler
kubectl rollout history deployment/adm-pea # посмотреть историю всех deployment
kubectl rollout status deployment/adm-pea #
kubectl describe deployment adm-pea # посмтреть подробнее про deployment
kubectl set image deployment/adm-pea nginx=nginx:version1 --record # обновить все image в pods
kubectl rollout undo deployment/adm-pea # вернуть все на предыдущую версию
kubectl rollout undo deployment/adm-pea --to-revision=4 # вернуть все на нужную версию
kubectl rollout restart deployment/adm-pea # обновить все до latest
kubectl get hpa # посмотерть нагрузку на deployment
kubectl apply -f deployment-1-simple.yml # создание из файла
kubectl delete -f deployment-1-simple.yml # удаление

# работа с SERVICES 
K8s Service Types - Виды K8s Service
При создании Service, ваше приложение будет доступно по:
ClusterIP - IP только Внутри K8S Cluster (default)
NodePort - определеный порт на ВСЕХ K8s Worker Nodes
ExternalName - DNS CNAME Record
LoadBalancer - Только в Cloud Clusters (AWS, GCP, Azure)

kubectl create deployment adm-pea --image adv4000/k8sphp:latest # создаем deployment
kubectl scale deployment adm-pea --replicas 3 # создаем реплики
kubectl expose deployment adm-pea --type=ClusterIP --port 80 # создаем сервис
kubectl expose deployment adm-pea --type=NodePort --port 80 # создаем сервис
kubectl expose deployment adm-pea --type=LoadBalancer --port 80 # создаем сервис
kubectl get services # посмотерть все services, можно писать svc
kubectl delete service adm-pea # удалить services

# INGRESS Controllers
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl get service -n projectcontour
kubectl create deployment main --image=adv4000/k8sphp:latest
kubectl create deployment web1 --image=adv4000/k8sphp:version1
kubectl create deployment web2 --image=adv4000/k8sphp:version2
kubectl create deployment webx --image=adv4000/k8sphp:versionx
kubectl create deployment tomcat --image=tomcat:latest
kubectl scale deployment main --replicas 2
kubectl scale deployment web1 --replicas 2
kubectl scale deployment web2 --replicas 2
kubectl scale deployment webx --replicas 2
kubectl expose deployment main --port=80
kubectl expose deployment web1 --port=80
kubectl expose deployment web2 --port=80
kubectl expose deployment webx --port=80
kubectl expose deployment tomcat --port=8080
nano ingress-hosts.yaml
kubectl apply -f ingress-hosts.yaml
kubectl get ingress

# Helm Charts
helm install App App-HelpChart/
helm install App App-HelpChart/ -f prod_values.yaml
helm install App App-HelpChart/ --set container.image=adv4000/k8sphp:version2
helm install App App-HelpChart/ -f prod_values.yaml --set ReplicaCount=4
helm create Chart-Auto # создать структуру автоматически
helm list # показать все созданные charts
helm upgrade App App-HelpChart/ -f prod_values.yaml --set ReplicaCount=4 # выполнить обновление
helm package App-HelpChart/ # запаковать в файл
helm install app4 App-HelpChart-0.1.0.tgz # создать из запакованного чарта
helm search repo # проверить сторонные репозитории
helm search hub apache # искать в общем чарте
helm install website bitnami/apache
helm delete app1

# ArgoCD 
это Open Source утилита, которая проверяет измеения в Git Repository и автоматически деплоит из этой Git Repository в k8s cluster.
Тоесть синхронизирует все ваши манифест файлы из Git в k8s.
https://www.youtube.com/watch?v=UwUZReDO4-4&list=PLg5SS_4L6LYvN1RqaVesof8KAf-02fJSi&index=13




~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ K8s - Поднятие простого Локального K8s Cluster на Windows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Источник: https://habr.com/ru/articles/734928/

# подготавлиеваем машинку
ufw disable # отключаем firewall
sudo apt update -y && sudo apt upgrade -y
apt install software-properties-common apt-transport-https ca-certificates gnupg2 gpg sudo -y
swapoff -a
nano /etc/fstab # комеентируем последнюю строку, выключаем swap
rm -rf /swap.img
modprobe overlay -v # overlay — этот модуль обеспечивает необходимую поддержку на уровне ядра для правильной работы драйвера хранения overlay. По умолчанию модуль overlay может не быть включен в некоторых дистрибутивах Linux, и поэтому необходимо включить его вручную перед запуском Kubernetes
modprobe br_netfilter -v # br_netfilter — этот модуль необходим для включения прозрачного маскирования и облегчения передачи трафика Virtual Extensible LAN (VxLAN) для связи между Kubernetes Pods в кластере
nano /etc/modules # добавляем в файл: echo "overlay" >> /etc/modules и echo "br_netfilter" >> /etc/modules построчно
echo 1 > /proc/sys/net/ipv4/ip_forward # включаем IP-пересылку в ядре Linux
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.ipv4.ip_forward=1
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
nano /etc/hosts # Добавляем список всех хостов
reboot


# ставим кубер
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y apt-transport-https ca-certificates curl
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl 

# ставим докер
apt-get update
apt-get install -y docker.io
systemctl enable docker
systemctl start docker

# запуск на мастере
kubeadm config images pull
kubeadm init --pod-network-cidr=10.100.0.0/16 --apiserver-advertise-address=192.168.56.1

# Настройте kubectl на мастер-ноде
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ставим плагин CNI на кластере
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# запуск на воркерах
kubeadm config images pull
kubeadm join 192.168.1.134:6443 --token p3rhb7.c65tmugsmebzgh5c \
        --discovery-token-ca-cert-hash sha256:373423bcde10a7e0a7746dbb97acee040a9c0f6b8785f07e2e1c0d0b96767103


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MicroK8s Поднятие простого Локального K8s Cluster на Windows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# установка на всех нодах
snap install microk8s --classic
alias mk='microk8s kubectl'
curl -LO https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/bin/kubectl
microk8s config > $HOME/.kube/config
kubectl version && kubectl get nodes,namespaces
echo 'alias k=kubectl' >>~/.bashrc
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc

microk8s add-node # просим создать строку подключения, выполняем на мастере
microk8s join ..... # выполняем на воркерах
microk8s enable dashboard dns registry metrics-server # включение служб
kubectl get pods --namespace kube-system # проверка запущенных сужб

# делаем проброс dashboard
nano k8s-dashboard.yml # вставляем:
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-np
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8443
    nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard

kubectl apply -f k8s-dashboard.yml
kubectl get services -A | grep -z "kubernetes-dashboard\|30000"

# делаем проброс dashboard
kubectl top nodes && kubectl top pods -n kube-system


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ minikube Поднятие простого Локального K8s Cluster на Windows ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Скачиваем
https://dl.k8s.io/release/v1.30.0/bin/windows/amd64/kubectl.exe
https://github.com/kubernetes/minikube/releases/download/v1.33.1/minikube-windows-amd64.exe
складываем в любую новую директорию

# Конфигурация kubectl: C:\Users\Onegi\.kube\config
# Директория ios minikube: C:\Users\Onegi\.minikube\machines\minikube

minikube config set driver virtualbox
minikube config set driver vmware
minikube config set driver hyperv
minikube version # Показать версию minikube
minikube start # Создать и запустить VM с K8s Cluster с параметрами по умолчанию
minikube stop # Остановить VM с нашим K8s Cluster
minikube delete # Удалить VM с нашим K8s Cluster
minikube ssh # Сделать Login на VM с нашим K8s Cluster
minikube start --cpus=2 --memory=4gb --disk-size=25gb # Создать и запустить VM с K8s Cluster с нашими параметрами
minikube start -p MYNAME # Создать и запустить VM с K8s Cluster с нашим именем

# Username: docker
# Password: tcuser
# root без пароля

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Поднятие Кластера в AWS Elastic Kubernetes Service - EKS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

awscli - нужен для аунтентификации и зпуска команд aws
kubectl - для управления K8s Cluster
eksctl - для создания K8s Cluster

eksctl create cluster --name peklichea # создать кластер
eksctl delete cluster --name peklichea # удалить кластер

eksctl create cluster -f mycluster.yaml # создать кластер из файла
eksctl delete cluster -f mycluster.yaml # создать кластер из файла

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Поднятие Кластера в GCP Google Kubernetes Engine - GKE  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Google Cloud SDK - нужен для создания K8s Cluster
kubectl - для управления K8s Cluster

gcloud version # показать версию
gcloud init # настроить gcloud с вашим Google Cloud
gcloud services enable container.googleapis.com # Включить создание K8s в вашем Google Cloud проекте
gcloud container clusters create peklichea # запустить создание кластера с имененм peklichea
gcloud container clusters create get-credentials peklichea # запустить настройку cubectl
gcloud container clusters create peklichea --num-nodes=2 # запустить создание кластера с имененм peklichea из 2 нод
gcloud container clusters delete peklichea # удалить кластер

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Поднятие Кластера для Учёбы Бесплатно в Интернете  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

https://labs.play-with-k8s.com/
Один кластер на 4 часа
В одном кластере максимум 5 нод

Следовать инструкции

kubectl label node node2 node-role.kubernetes.io/worker= # изменить label


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Создание Docker Image, DockerHub, Запуск Docker Container  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

docker build -t myk8sapp . # Создать DockerImage из локального Dockerfile
docker login # Зайти в DockerHub
docker tag myk8sapp:latest adv4000/k8sphp:latest # Переименовать Docker Image
docker push # Загрузить Image в Repository
docker images # Показать все локальные Docker Images
docker rmi XXXXXXXXX -f # Удалить локальный DockerImage с ID XXXXXXXXX
docker run -it -p 1234:80 adv4000/k8sphp:latest # Запустить контейнер на порту 1234 с нашим DockerImage








