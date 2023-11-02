#!/bin/bash

version="v0.1.0"

display_help() {
  cat << EOF
Usage: internsctl [OPTIONS] COMMAND [ARGUMENTS]

Custom Linux command for various system operations.

Options:
  --help               Display help information and examples.
  --version            Display the version of the command.

Commands:
  cpu getinfo          Display CPU information.
  memory getinfo       Display memory information.
  user create <username>  Create a new user with login access.
  user list            List all regular users.
  user list --sudo-only  List all users with sudo permissions.
  file getinfo <file-name>  Get information about a file.
  file getinfo --size <file-name>  Get the size of a file.
  file getinfo --permissions <file-name>  Get file permissions.
  file getinfo --owner <file-name>  Get the owner of a file.
  file getinfo --last-modified <file-name>  Get last modified time of a file.

Examples:
  internsctl cpu getinfo
  internsctl memory getinfo
  internsctl user create john
  internsctl user list
  internsctl user list --sudo-only
  internsctl file getinfo hello.txt
  internsctl file getinfo --size hello.txt
  internsctl file getinfo --permissions hello.txt
  internsctl file getinfo --owner hello.txt
  internsctl file getinfo --last-modified hello.txt

Report bugs to your_email@example.com
EOF
}

case "$1" in
  --help)
    display_help
    ;;
  --version)
    echo "internsctl $version"
    ;;
  cpu)
    if [ "$2" = "getinfo" ]; then
      lscpu
    else
      echo "Invalid command: $2"
      exit 1
    fi
    ;;
  memory)
    if [ "$2" = "getinfo" ]; then
      free
    else
      echo "Invalid command: $2"
      exit 1
    fi
    ;;
  user)
    if [ "$2" = "create" ]; then
      if [ -z "$3" ]; then
        echo "Error: Username not provided."
        exit 1
      fi
      adduser "$3"
    elif [ "$2" = "list" ]; then
      if [ "$3" = "--sudo-only" ]; then
        getent passwd | awk -F: '$3 >= 1000 {print $1}' | xargs -I {} sudo -lU {}
      else
        getent passwd | awk -F: '$3 >= 1000 {print $1}'
      fi
    else
      echo "Invalid command: $2"
      exit 1
    fi
    ;;
  file)
    if [ "$2" = "getinfo" ]; then
      if [ -z "$3" ]; then
        echo "Error: File name not provided."
        exit 1
      elif [ $(echo $3 | cut -c1-1) != "-" ]; then
	echo "File: $3"
        echo `stat -c "Access: \t%A\nSize(B): \t%s\nOwner: \t\t%U\nModify: \t%y" "$3"`
	exit 1
      fi
      if [ -z "$4" ]; then
	echo "Error: File name not provided."
	exit 1
      fi
      filename="$4"
      if [ "$3" = "--size" ]; then
        stat -c %s "$filename"
      elif [ "$3" = "--permissions" ]; then
        stat -c %A "$filename"
      elif [ "$3" = "--owner" ]; then
        stat -c %U "$filename"
      elif [ "$3" = "--last-modified" ]; then
        stat -c %y "$filename"
      else
	echo "Invalid command: $3"
	exit 1
      fi
    fi
    ;;
  *)
    echo "Invalid command: $1"
    exit 1
    ;;
esac
