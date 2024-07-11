настройка серверов:

sudo gluster peer probe glstr-n1, glstr-n2, glstr-n3 # Первым делом надо сделать так, чтобы сервера видели друг друга.
sudo gluster peer status # Проверить, что все прошло успешно
mkdir /gluster/brick0 # Далее создадим папку, которая будет служить нам brick'ом.
gluster volume create gv replica 3 glstr-n1:/gluster/brick glstr-n2:/gluster/brick glstr-n3:/gluster/brick # Создадим том. Это можно выполнить один раз на любой из нод кластера.
gluster volume start gv # Запускаем том

настройка клиента: 
mkdir /gluster-storage # Создаем каталог.
# Монтируем том стразу через /etc/fstab. Добавляем строку
# Параметр: backupvolfile-server=glstr-n2:glstr-n3 – указывает на дополнительные ноды кластера.
glstr-n1:gv	/gluster-storage 	glusterfs 	defaults,_netdev,backupvolfile-server=glstr-n2:glstr-n3	 	0 	0
mount -a # Перечитываем fstab.


Управление кластером
Перечислю несколько базовых команд для управления кластером. Запустить их можно с любого узла кластера.

sudo gluster help # Справка
sudo gluster volume help # Справка

sudo gluster volume heal gv info # Покажет информацию о рассинхронизованых файлах на томе, если таковые есть.
sudo gluster volume info gv # Покажет информацию о томе.
sudo gluster volume heal gv0 # Ручная синхронизация файлов.
sudo gluster volume get gv all # Кластер имеет множество настроек. Посмотреть их можно командой:

# sudo gluster volume set gv [ИмяПараметра] [ЗначениеПараметра], например:
sudo gluster volume set gv performance.cache-size 256MB # Переопределить параметры

cluster.favorite-child-policy
Политика автоматического восстановления после split-brain. Может принимать следующие значения:
    none: Значение по-умолчанию;
    size: Приоритет буду иметь файлы большего размера;
    ctime: Приоритет будут иметь файлы с более поздней датой изменения прав доступа или владельца;
    mtime: Приоритет будут иметь файлы с более поздней датой изменения;
    majority: выбирает файл с одинаковым mtime и размером более чем в половине количества brick в реплике.

performance.readdir-ahead и performance.parallel-readdir
Повышает производительность листинга каталогов.
Значения: on\off

Операции чтения небольших файлов
performance.cache-invalidation on
features.cache-invalidation on
performance.qr-cache-timeout 600 --> 10 min recommended setting
cache-invalidation-timeout 600 --> 10 min recommended setting











 



