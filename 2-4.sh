#!/bin/bash

# Проверяем количество аргументов
if [ "$1" == "--help" ]; then
    echo "Необходимо указать список пользовательских групп"
    echo "Пример для добавления: group1:user1,user2 group2:user3,user4"
    echo "Для удаления запустите прoграмму с флагом -d"
    echo "Пример для удаления: group1 group2"
    exit 1
fi

# Проверяем опцию -d
if [ "$1" == "-d" ]; then
  # Удаляем группы
  read -p "Введите через пробел список групп для удаления: " groups
  for group in $groups
  do
    # Проверяем, существует ли группа
    if grep -q "^$group:" /etc/group; then
      # Удаляем группу
      sudo groupdel $group
      echo "Группа $group удалена"
    else
      echo "Группа $group не существует"
      exit 1
    fi
    shift
  done
else
  # Создаем группы и добавляем пользователей
  read -p "Введите список для добавления: " groups
  for input in $groups
  do
    if ! echo $input | grep -q ":"; then
      echo "Некорректный ввод"
      exit 1
    fi
    group=$(echo $input | cut -d':' -f1)
    users=$(echo $input | cut -d':' -f2)

    # Проверяем, существует ли группа
    if grep -q "^$group:" /etc/group; then
      echo "Группа $group уже существует"
      exit 1
    else
      # Создаем новую группу
      sudo groupadd $group
      echo "Группа $group создана"
    fi

    # Добавляем пользователей в группу
    for user in $(echo $users | tr ',' ' '); do
      # Проверяем, существует ли пользователь
      if id -u $user >/dev/null 2>&1; then
        echo "Пользователь $user найден"  
      else
        # Создаем нового пользователя
        sudo useradd $user
        echo "Пользователь $user создан"
      fi
      # Добавляем пользователя в группу
      sudo usermod -G $group $user
      echo "Пользователь $user добавлен в группу $group"
    done
    shift
  done
fi

exit 0
