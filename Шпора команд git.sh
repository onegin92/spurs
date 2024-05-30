
#-- Git - Конфигурация gitconfig
git config --global user.name "Peklichea" # задаем пользователя
git config --global user.email peklichea@gmail.com # задаем email
git config -l # просмотр настроек
linux config file: /home/myuser/.gitconfig
windows config file: c:\Users\myuser\.gitconfig


#-- Git - Работа с Local Repository
git init .
git add * или git add .
git status
git commit -m "My initail version"


#-- Git - История изменений | gitignore | восстановление файлов
git log # показать коммиты
git log -2 # показать последние 2 коммита
git log -2 -p # показать изменения в последних двух коммитах
git diff --staged # показать что будет записано в log после git commit
git checkout -- file1.txt # откатить изменения файла со стасусом modifed

файл .gitignore # указать исключения для git


#-- Git - Создание и работа с Ветвлениями - Branch
git branch # показать branch
git branch adm-pea # создать branch с названием adm-pea
git checkout adm-pea # переключиться на branch adm-pea
git branch -d adm-pea # удалить branch adm-pea
git checkout -b adm-pea # создать и переключиться на branch adm-pea
git merge adm-pea # соеденить branch, но перед этим нужно переключиться на master branch
git branch -D adm-pea # удалить branch со всеми изменениями


#-- Git - Возврат на предидущие версии
git log # смотрим коммиты, копируем номер хеша
git checkout ckasd09123123asdasd # откатиться до нужного коммита
git checkout master # вернуться на последнюю версию
git commit --amend # редактировать commit 
git reset --hard HEAD~2 # откатиться на 2 коммита вниз с удалением только верних коммитов
git reset --soft HEAD~3 # откатиться на 3 коммита с удалением всех остальных коммитов


#-- Git - Полный рабочий цикл действий Git и GitHub
git clone git@github.com:adm-pea/project-1.git # клонировать проект из git
git branch # посмтреть все branch
git checkout -b adm-pea # создать и переключиться на branch adm-pea
правим код, тестируем
git status # смотрим изменения
git add . 
git commit -m "bla bla bla"
git push origin # не выполнится, но покажет команду для пуша branch
git push --set-upstream origin adm-pea # пуш всего branch в git
в git делаем Open a pull reques, запрос на объединение с branch master
начальник делает merge в гит
git checkout master # переходим на master branch
git branch # проверяем на каком мы branch
git branch -d adm-pea #удаляем наш branch
git push origin --delete adm-pea # удалить branch в git


#-- Git - Как работать с тегами в репозитории Git на примере GitHub - Git Tags
git log --pretty=oneline # просмотр изменений с тегами 
git tag # просмотр tag
git tag v1.0.0 # создаем tag
git log --pretty=oneline # проверить tag
git push origin v1.0.0 # запушить tag
git tag -d v1.1.0 # удалить tag

git push origin --delete v1.1.0 # удалить tag в git
git pull # скачать обновления из git
git checkout v1.0.0 # перейти на коммит с тегом v1.0.0
git checkout main # вернуться на последнюю версию
git tag -a v1.5.0 asdasdasd123asdsd123123asd # добавить tag на нужный нам коммит
git push origin --tags # запушить все tags в hit


#-- Git - Как удалить из истории секретную информацию локально и на удалённом репозитории
git reset --hard HEAD~1 # откатиться на 1 коммита вниз с удалением только верних коммитов
git push origin main --force # перезаписать историю в git в branch main


#-- GitHub Actions - Основы Автоматизации - DevOps - GitOps
gitgub actions - позволяет запускать limux или windows комманды, а также автоматизировать test, build, deploy нашего кода 
в repository github без поднятия серверов для этой автоматизации, типа Jenkins
Включение автоматизации происходит добавлением файлов YAML в специальную директорию .github/workflows/ в ваш Repository