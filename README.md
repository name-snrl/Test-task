# Решение тестового задания.

## Tasks

1. Сервер начал долго отвечать на сетевые запросы. Какими будут Ваши действия и
   какими утилитами будете пользоваться? (ОС GNU/Linux)
2. На виртуальной машине, где установлена СУРБД, начало заканчиваться дисковое
   пространство. Как увеличить дисковое пространство, не прерывая работу БД?
   Нужна ли какая-то предварительная настройка системы для решения данной
   задачи? (ОС GNU/Linux)
3. Как максимально обезопасить доступ к демону sshd при условии, что доступ к
   нему должен осуществляться через интерфейс, подключенный к Интернету?
4. Необходимо написать команду, которая перенесет все файлы директорий старше 10
   дней на удаленный сервер (файлы могут находиться во вложенных директориях).\
   Условия:
   - Использовать `rsync(1)` и `find(1)`.
   - Структура каталогов должна быть сохранена.
   - Время модификации файла должно быть сохранено.
   - Ограничение по скорости передачи файлов - 24Мбит/сек.
   - Исходные файлы по завершении транзакции должны быть удалены.
5. Написать скрипт (bash, python, ...), который периодически проверяет
   доступность web-сервиса и в случае его недоступности отправляет email
   системному администратору, но не чаще 1-го раза за "падение".
6. Необходимо создать systemd юнит для python скрипта. Назовем его
   custom.service.\
   Условия:
   - Путь к исполняемому файлу - `/opt/CustomApp/custom.py`
   - В аргументы скрипт принимает ключи `--stop`, `--start`
   - При падении скрипта, сервис должен автоматически перезагрузиться.
   - Запускаться он должен от имени пользователя user321.
   - Ограничение по потребляемой оперативной памяти скриптом не должно превышать
     512MB.

## Answers

1. Я бы начал с сети, команды `ping`, `tracerout`, `mtr`. Если проблема с сетью и
   находится на моем уровне компетенции, то нужно непосредственно разбираться с
   узлом сети, который доставляет проблемы.\
   Следующий шаг - проверить ресурсы сервера. Тут нам может пригодиться
   такая команда как `top`/`htop`. Также стоит обратить внимание на дисковую
   подсистему. Посмотреть SMART диска, занятое пространство, запустить тест
   скорости. `smartctl`, `df`, `lsblk`, `hdparm`, `dd`\
   Ресурсов хватает и с сетью все ок? Возможно дело в сервисе, который
   обрабатывает наши запросы. Тут уже все зависит от того какой сервис,
   но что точно нужно сделать, так это погулять по логам.
2. Да, нужно предварительно настроить подсистему lvm. Создать lvm группу (VG), в
   которую в последующем мы сможем добавить новый физический том (PV). PV же мы
   сможем создать из нового блочного устройства, которое мы подключим к серверу.
   По завершении этих процедур нам остается лишь расширить наш логический том
   (LV).
3. Сменить порт, прокинуть ключи, запретить вход по паролю, запретить вход от
   рута. Настроить 2FA (этого нет в [скрипте](task03.sh)).
4. Шаблон:
   ```bash
   find path/to/dir -type f -mtime +10 | sed 's#remove_part/of/path_to_dir##' |
       rsync \
       --dirs \
       --times \
       --bwlimit=3Mib \
       --remove-source-files \
       --files-from=- \
       path_to_dir/where_files_can_be_find \
       userName@hostName:path/to/backup/dir
   ```
   Пример использования:
   ```bash
   cd ~
   find downloads/Kotatogram\ Desktop/ -type f -mtime +10 |
       sed 's#^downloads/##' |
       rsync \
       --dirs \
       --times \
       --bwlimit=3Mib \
       --remove-source-files \
       --files-from=- \
       downloads/ \
       root@192.168.122.206:~/backup
   ```
   На удаленном хосте получим папку `Kotatogram Desktop` с требуемым содержимым.
   P.s. возможно требовалось использовать `find(1)` с ключем `-exec`, но мне
   хотелось удалить лишнюю часть пути при копировании.
5. [Клац](task05.sh).
6. [Клац](task06.sh).
