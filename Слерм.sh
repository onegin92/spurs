Слерм

#----------------------------------------------------------------- Урок 2: Создание своего кластера в MCS. -----------------------------------------------------------------#
cd /root/slurm/school-dev-k8s/practice/3.application-abstractions/1.pod
k create -f pod.yaml # создать pod из файла
k get pods # посмотреть все pods
k describe pod my-pod # посмотреть описание pod
k delete -f pod.yaml # удалить pods

#----------------------------------------------------------------- Урок 3: Абстракции приложения. -----------------------------------------------------------------#
kubectl completion -h # настраиваем по инструкции https://kubernetes.io/ru/docs/tasks/tools/install-kubectl/
k apply -f replicaset.yaml # создать или обновить RS
k get rs # постмреть список всех RS
k get pods 
k set image replicaset my-replicaset '*=quay.io/testing-farm/nginx:1.13' # обновить образ
k edit deployments.apps my-deployment # изменить конфигурацию
k rollout undo deployment my-deployment # откатить изменения
k rollout history deployment my-deployment # посмотерь историю ревизий
k explain deployment.spec.strategy # посмотерь документацию
kubectl patch deployment my-deployment --patch '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","resources":{"requests":{"cpu":"10"},"limits":{"cpu":"10"}}}]}}}}' # изменить конфигурацию

#----------------------------------------------------------------- Урок 4: Хранение конфигураций. -----------------------------------------------------------------#
k apply -f configmap.yaml
k get cm # посмотреть созданные configmap
kubectl create secret generic test --from-literal=test1=asdf --from-literal=dbpassword=1q2w3e
k get pods -o wide # расширенный вывод информации о поде

#----------------------------------------------------------------- Урок 5: Хранение данных. -----------------------------------------------------------------#
Типы томов: 
 - configMap # служебный том, позволяет создать в контейнере том с файлами из манифестов Kubernetes
 - secret # служебный том, позволяет создать в контейнере том с файлами из манифестов Kubernetes
 - emptyDir # временный том, создаётся только на время жизни пода
 - hostPath # позволяет смонтировать внутрь контейнера с приложением любой каталог локального диска сервера, на котором работает приложение. политики безопасности запрещают использовать

SC/PVC/PV:
 - Storage class # хранит параметры подключения к системе хранения данных
 - PersistentVolumeClaim # описывает требования к тому, который нужен приложению
 - PersistentVolume # хранит параметры доступа и статус тома
Provisioner - создает тома, Эта программа подключается к СХД, создаёт том нужного размера, получает идентификатор и создает в кластере Kubernetes манифест PersistentVolume, который связывается с PersistentVolumeClaim

k edit pvc fileshare # увеличить размер диска pvc

initContainers # позволяет выполнить настройки перед запуском основного приложения
# выполняются по порядку описания в манифесте
# можно монтировать те же тома, что и основных контейнерах
# можно запусать от другого пользователя
# должен выполнить действие и остановиться

ReadWriteMany
cephFS # можно примапить ко всем узлам
RBD # можно примапить только к одному узлу

#----------------------------------------------------------------- Урок 6: Сетевые абстракции.  -----------------------------------------------------------------#
Probes
Liveness Probe 
- Контроль за состоянием приложения во время его жизни
- Исполняется постоянно
- переапуск пода в случае ощибки
Readiness Probe 
- Проверяет, готово ли приложение принимать трафик
- В случае неудачного выполнения приложение убирается из балансировки
- Исполняется постоянно
Startup Probe # 
- Проверяет, запустилось ли приложение
- Исполняется при старте

readinessProbe:
  failureThreshold: 3 # допустимое кол-во проваленный попыток
  httpGet: # тип проверки, еще есть tcp socket и exec
    path: /
    port: 80
  periodSeconds: 10 # с какой периодичностью делать проверку
  successThreshold: 1 # необходимое количство успешных попыток для сброса счетчика failureThreshold
  timeoutSeconds: 1 # timeout выполнения проверки
livenessProbe:
  failureThreshold: 3 # допустимое кол-во проваленный попыток
  httpGet: # тип проверки, еще есть tcp socket и exec
    path: /
    port: 80
  periodSeconds: 10 # с какой периодичностью делать проверку
  successThreshold: 1 # необходимое количство успешных попыток для сброса счетчика failureThreshold
  timeoutSeconds: 1 # timeout выполнения проверки
  initialDelaySeconds: 10 # скоклько секунд подождать после запуска приложения 
startupProbe:
  httpGet: # тип проверки, еще есть tcp socket и exec
    path: /
    port: 80
  failureThreshold: 30 # допустимое кол-во проваленный попыток
  periodSeconds: 10 # с какой периодичностью делать проверку

Типы Service:
ClusterIP # IP только Внутри K8S Cluster (default)
NodePort # определеный порт на ВСЕХ K8s Worker Nodes
LoadBalancer # Только в Cloud Clusters (AWS, GCP, Azure)
ExternalName - DNS CNAME Record
ExternalIPs
Headless

Ingress Controller


#----------------------------------------------------------------- Урок 7: Устройство кластера.  -----------------------------------------------------------------#
 - Etcd 
    # Хранит всю информацию о кластере
 - API server 
    # Центральный компонент Kubernetes
    # Единственный кто общается с Etcd
    # Работает по REST API
    # Authentication and authorization
 - Controller-manager
    # Набор контроллеров (Node controller, Replicaset controller, Endpoints controller и т.д.)
    # GarbageCollector – «сборщик мусора»
 - Scheduler
    # Назначает PODы на ноды, учитывая: (QoS, Affinity/anti-affinity, Requested resources, Priority Class и т.д.)
 - Kubelet
    # Работает на каждой ноде
    # Обычно единственный компонент, работающий не в Docker
    # Отдаёт команды Docker daemon
    # Создаёт PODы
 - Kube-proxy
    # Смотрит в Kube-API
    # Стоит на всех серверах
    # Управляет сетевыми правилами на нодах
    # Фактически реализует Service (ipvs и iptables)
 - Контейнеризация
 - Сеть
 - DNS



#----------------------------------------------------------------- Урок 8: Локальная разработка в K8s. -----------------------------------------------------------------#
Minikube
 # Имплементация локального Kubernetes
 # Максимально простая установка и запуск
 # Поддерживается большинство фич Kubernetes
 # Система аддонов
Запуск кластера
 # Запускается внутри виртуальной машины
 # Драйверы виртуализации:
    # Docker – default (но не работают ингрессы)
    # Virtual Box – универсальный выбор для всех ОС
    # Hyperkit – MacOS
    # HyperV – Windows
    # KVM – Linux


 
#----------------------------------------------------------------- Урок 9: Oneshot задачи. -----------------------------------------------------------------#
Job 
# Создает под для выполнения задачи
# Перезапускает поды до успешного выполнения задачи или истечения таймаутов
  # activeDeadLineSeconds
  # backoffLimit
apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  backoffLimit: 2 # лимит на количество попыток запуска
  activeDeadlineSeconds: 60 # лимит по времени
  template:
    spec:
      containers:
      - name: hello
        image: quay.io/prometheus/busybox
        args:
        - /bin/sh
        - -c
        - date; echo Hello from the Kubernetes cluster
      restartPolicy: Never # политика рестарта контейнеров, выключена чтобы отдебажить

CronJob
# Создает Job по расписанию
# Важные параметры
  # startingDeadlineSeconds
  # concurrencyPolicy
  # successfulJobsHistoryLimit
  # failedJobsHistoryLimit
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Allow # 
  jobTemplate:
    spec:
      backoffLimit: 2
      activeDeadlineSeconds: 100
      template:
        spec:
          containers:
          - name: hello
            image: quay.io/prometheus/busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: Never


#----------------------------------------------------------------- Урок 10: Альтернатива Deployment. -----------------------------------------------------------------#
Задача мониторинга
  # На каждой ноде автоматически запускается агент
  # Управляются агенты из одной точки
  # Конфигурируются так же из одной точки

DaemonSet
  # Запускает поды на всех нодах кластера
  # При добавлении ноды – добавляет под
  # При удалении ноды GC удаляет под
  # Описание практически полностью соответствует Deployment

Tolerations
# исключения, где поды не будут подниматься

StatefulSet
# Позволяет запускать группу подов (как Deployment)
  # Гарантирует их уникальность
  # Гарантирует их последовательность
# PVC template
  # При удалении не удаляет PVC
# Используется для запуска приложений с сохранением состояния
  # Rabbit
  # DBs
  # Redis
  # Kafka
  # …

Affinity # позволяет подсказать и ипотребовать как размещать поды по узлам кластера

Headless Service
#.spec.clusterIP: None
# Резолвится в IP всех эндпоинтов
# Создает записи с именами всех эндпоинтов

#----------------------------------------------------------------- Урок 11: Авторизация в кластере. -----------------------------------------------------------------#
RBAC
# Role
# RoleBinding
# ClusterRole
# ClusterRoleBinding
# ServiceAccount

k get clusterrole
k get role -n ingress-nginx
k get role -n ingress-nginx ingress-nginx -o yaml
k get rolebinding -n ingress-nginx ingress-nginx -o yaml

RoleBinding

k apply -f erviceaccount.yaml
k get sa <name> -o yaml
k get secret <secretname> -o yaml # токен тут закодирован
k describe secret <secretname> # токен раскодирован

k apply -f rolebinding.yaml
k get rolebinding

k apply -f secret.yml
kubectl get secret --as=system:serviceaccount:s<номер студента>:user # Пробуем получить список secret под юзером

# описание кластеров, куда можем подключаться
kubectl config set-cluster slurm.io \
--server https://172.20.100.2:6443 \
--certificate-authority=/etc/kubernetes/pki/ca.crt \
--embed-certs=true
#описание пользователей под которыми будуем подключаться и способ аутентификации
kubectl config set-credentials username \
--token BFG9000js23..==
# связываем кластер, пользователя и namespace
kubectl config set-context slurm.io \
--user username \
--cluster slurm.io \
--namespace default
# указываем контекст, который будем использовать, можно переключать
kubectl config use-context slurm.io

kubectl config # показывает документашку
kubectl config view # посомтреть текущий конфиг
kubectl config set-context --corrent --namespace # меняем контекст по умолчанию

Resource Quota # Устанавливает количество доступных ресурсов и объектов для нэймспэйса в кластере
  # Реквесты
  # Лимиты
  # Сервисы
  # Поды
  # ...
k get resourcequotas resource-quota -o yaml # квоты
k get limitranges limit-range -o yaml # выдает дефолты для подов где не описаны реквесты и лимиты, ограничивает потребление одного контейнера в поде

Pod Security Policy # запрещает запуск подов с не безопасными механизмами, например поды подключающие тома типа hostpash
  # Контролирует аспекты безопасности в описании Pod’ов
  # Включается как admission controller plugin “PodSecurityPolicy”
    # При включении запрещает запуск Podов без PSP

#------------------------------------------------ Урок 12: Использование JupyterHub в Kubernetes для тестирования oneAPI от Intel --------------------------------------------------#
Jupyter и JupyterHub
# Jupyter – open source интерактивная web среда для разработки, проведения экспериментов, построения визуализаций
# Используется аналитиками, data science и data engineering командами
# Поддерживает различные языки, включая Python, Scala, R, Julia
# Есть поддержка расширений, можно настроить под различные задачи
# JupyterHub – multi-user версия Jupyter, решающая задачи аутентификации, предоставления индивидуальных окружений, масштабирования


#------------------------------------------------ Урок 13: Особенности ЯП в Kubernetes. --------------------------------------------------#





#------------------------------------------------ Урок 14: Kubernetes и работа с данными --------------------------------------------------#

Spark
# Apache Spark - is a multi-language engine for executing data engineering, data science, and machine learning on single-node machines or clusters
# Умеет работать с Yarn, Mesos, Kubernetes и в Standalone режиме
# Пришел на смену Hadoop MapReduce
# Чаще всего идет в комплекте с Hadoop кластером

Почему стоит запускать Spark в Kubernetes
# Изоляция сред (контейнеризация и dependency management)
# Управление ресурсами
# Гибкое масштабирование
# Разделение storage и compute слоёв

#------------------------------------------------ Урок 15: Дебаг приложений в кластере --------------------------------------------------#

Три главные команды
# kubectl describe …
# kubectl get events
# kubectl logs <pod_name> [--previous]

terminationMessagePolicy: FallbackToLogsOnError # Выведет в describe последние 80 строчек или 2Ki лога


#------------------------------------------------ Решения для Deep & Machine Learning --------------------------------------------------#

реклама intel


#------------------------------------------------ Урок 17: Автоскейлинг в кластере Kubernetes --------------------------------------------------#

HPA - Horizontal Pod Autoscaler
k top node # посмотр нагрузки на ноду, можно заменить на pod
k get po -w # типо tail -f
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=5 # при достижении 50 процентов, увеличивать реплики
k get hpa # просиотр всех hpa
kubectl run load-generator --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done" # создаем нагрузку

Cluster Autoscaler
# Автоматически добавляет новые ноды в кластер
# Реализуется на стороне провайдера
# Может быть использован не только совместно с HPA

# Динамические раннеры CI/CD
# Динамические стэнды


#------------------------------------------------ Урок 18: Темплейтирование приложений --------------------------------------------------#

Почему Helm?
# «Пакетный менеджер»
# CNCF
# Декларативный
# Есть важные фичи для построения CD
  # Watch
  # Rollback
  # Hooks
# Система плагинов

Основы работы с Helm
• helm search – поиск чарта
• helm install – установка чарта
• helm upgrade – обновление чарта
• helm get – скачать чарт
• helm show – показать инфу о чарте
• helm list – список установленных чартов
• helm uninstall – удалить чарт

Деплой приложения
• helm repo add southbridge https://charts.southbridge.ru/
• helm search hub kube-ops
• helm show values southbridge/kube-ops-view > values.yaml
• helm install ops-view southbridge/kube-ops-view -f values.yaml
• helm ls

Что внутри
• helm pull southbridge/kube-ops-view
• tar -zxvf kube-ops-view-XX.YY.tgz
• cd kube-ops-view/

Пишем свой чарт
1. Добавляем темплэйты в labels
2. Находим https://helm.sh/docs/topics/chart_best_practices/labels/
3. Добавляем темплэйты в image
4. Добавляем темплэйты в реплики
5. Добавляем темплэйты в ресурсы
6. Добавляем темплэйты в env

helm template . # вывести все монифесты с подставленными значениями
helm template . --name-template=foobar --set image.tag=1.13

Пишем свой 100ый чарт
• Узнаем про команду helm create chart_name
• Узнаем, что можно создавать свои стартеры

Тестирование релиза
1. Создаем папку templates/tests/
2. Кладем туда манифесты объектов k8s которые будут тестить релиз
3. Манифесты должны содержать аннотацию helm.sh/hook: test
4. Запускаем в CI helm test <release name>

Хуки
1. pre-install, post-install, pre-delete, post-delete, pre-upgrade, post-upgrade, pre-rollback, post-rollback
2. Это те же манифесты k8s
3. Одинаковые хуки сортируются по весу и имени объекта
4. Сперва отрабатывают объекты с меньшим весом (от - к +)
5. Хуки не входят в релиз (helm.sh/hook-delete-policy)

Где хранить чарты Helm?
1. Сделать свой репо на базе веб-сервера
2. Хранить чарты вместе с исходным кодом в отдельной папке

Library Charts
1. Библиотечные чарты позволяют сделать ещё более универсальные шаблоны
2. Добавлять их в основной чарт нужно как зависимости
3. Сами библиотечный чарты установить нельзя, они лишь основа генерации шаблона

