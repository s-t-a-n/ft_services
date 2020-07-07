#!/bin/sh
# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    setup.sh                                           :+:    :+:             #
#                                                      +:+                     #
#    By: sverschu <sverschu@student.codam.n>          +#+                      #
#                                                    +#+                       #
#    Created: 2020/07/04 14:00:11 by sverschu      #+#    #+#                  #
#    Updated: 2020/07/04 14:00:11 by sverschu      ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

# OS Detection
KERNEL="$(uname -s)"

# Global flags/vars
MINIKUBE_FLAGS=
ACTION=

export MINIKUBE_IN_STYLE=false # disable childish emoji

case $KERNEL in
	Darwin)
		MINIKUBE_FLAGS+=--vm-driver=virtualbox
		;;
	Linux)
		;;
esac


DEPENDENCIES=(docker kubectl minikube)
function clean_up()
{
	case $1 in
		INT)
			logp fatal "aborting.."
		;;
		EXIT)
		#logp endsection
		;;
		TERM)
			logp fatal "aborting.."
		;;
	esac
}

trap "clean_up INT" INT
trap "clean_up TERM" TERM
trap "clean_up EXIT" EXIT

function logp()
{ 
	case "$1" in
		info)
			zsh -c "echo -e \"\e[32m\e[1m* \e[0m$2\""
			;;
		warning)
			zsh -c "echo -e \"\033[31m\e[1m* \e[0m$2\""
			;;
		fatal)
			zsh -c "echo -e \"\e[31m\e[1m* \e[0m\e[30m\e[101m$2\e[0m\""
			exit 1
			;;
		beginsection)
			zsh -c "echo -e \"\e[1m\e[33m*********************************************************************************************\""
			zsh -c "echo -e \"\e[1m\e[33m|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\e[0m\""
			;;
		endsection)
			zsh -c "echo -e \"\e[1m\e[33m|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\""
			zsh -c "echo -e \"\e[1m\e[33m*********************************************************************************************\e[0m\""
			;;
	esac
}

function banner()
{
clear
zsh -c "echo -e \"\e[31m\e[1m\"
cat<<EOF
EOF"
#logp beginsection
}

function usage()
{
	echo USAGE
	exit 1
}

function handle_flags()
{
	if [ $# -eq 0 ]; then usage; fi

	# read action options
	for ARG in $@
	do
		if [ "${ARG}" == "start" ]; then ACTION="start"; break; fi
		if [ "${ARG}" == "stop" ]; then ACTION="stop"; break; fi
		if [ "${ARG}" == "purge" ]; then ACTION="purge"; break; fi
	done
	if [ "$ACTION" = "" ]; then
			logp fatal "No run command specified! (run $0 -h for usage)"
	fi

	while getopts "m:i:p:l:r:sh" ARG; do
		case "${ARG}" in
			h)
				usage
				;;
			m)
				((${OPTARG} > 0)) || _usage
				EXT_FLAGS="$EXT_FLAGS -D MEMSIZE=${OPTARG}"
				;;
			i)
				((${OPTARG} > 0)) || _usage
				EXT_FLAGS="$EXT_FLAGS -D ITERATIONS=${OPTARG}"
				;;
			s)
				EXT_FLAGS="$EXT_FLAGS -fsanitize=address -D FSANITIZE_ADDRESS=1"
				logp warning "--- Don't forget to ADD -fsanitize=address to your flags (like -Wall -Werror -Wextra) in your libasm makefile before compiling!"
				;;
			r)
				((${OPTARG} == 0)) && EXT_FLAGS="$EXT_FLAGS -D RANDOMIZED_TESTS=0"
				((${OPTARG} == 1)) && EXT_FLAGS="$EXT_FLAGS -D RANDOMIZED_TESTS=1"
				((${OPTARG} == 0)) || ((${OPTARG} == 1)) || _usage

				;;
			*)
				_usage
				;;
		esac
	done
	shift $((OPTIND-1))
}

function perform_actions()
{
	case $ACTION in
		start)
			logp info "Starting..."
			minikube_wrap start
		exit $?
		;;
		stop)
			logp info "Stopping..."
			minikube_wrap stop
			exit $?
		;;
		purge)
			logp info "Purging..."
			case $KERNEL in
				Darwin)
					minikube_wrap stop
					rm -rf ~/goinfre/minikube
					rm -rf ~/goinfre/docker
					VBoxManage controlvm "minikube" poweroffip 2>/dev/null 
					VBoxManage unregistervm --delete "minikube" 2>/dev/null
					exit 0
				;;
				Linux)
					minikube_wrap stop
					rm -rf ~/.minikube
					rm -rf ~/.docker
					VBoxManage controlvm "minikube" poweroffip
					VBoxManage unregistervm --delete "minikube"
					exit 0
			esac
		;;
	esac
}

function check_env()
{
	for dep in "${DEPENDENCIES[@]}"
	do
		if ! command -v $dep &> /dev/null; then
			if [ "$KERNEL" = "Darwin" ]; then
				logp fatal "Dependency '$dep' was not met! -> suggesting 'brew install $dep'"
			else
				logp fatal "Dependency '$dep' was not met!"
			fi
		fi
	done
}

function setup_env()
{
	case $KERNEL in
		Darwin)
			if [ ! -d ~/goinfre/docker ] || [ ! -L ~/Library/Containers/com.docker.docker ]
			then
				logp info "Setting up Docker folder @ ~/goinfre/docker!"
				rm -rf ~/Library/Containers/com.docker.docker
				mkdir ~/goinfre/docker
				ln -s ~/goinfre/docker ~/Library/Containers/com.docker.docker
			fi
			if [ ! -d ~/goinfre/minikube ] || [ ! -L ~/.minikube ]
			then
				logp info "Setting up Minikube folder @ ~/goinfre/minikube!"
				rm -rf ~/.minikube
				mkdir ~/goinfre/minikube
				ln -s ~/goinfre/minikube ~/.minikube
			fi
		;;
	esac
}

function minikube_wrap()
{
	case $1 in
		start)
			if ! minikube status 2>/dev/null 1>/dev/null; then
				minikube start $MINIKUBE_FLAGS
				return $?
			fi
			eval $(minikube docker-env)
		;;
		stop)
			if minikube status 2>/dev/null 1>/dev/null; then
				minikube stop
				return $?
			fi
		;;
	esac
}


function kubernetes()
{
	if ! minikube_wrap start; then
		logp fatal "Couldn't start minikube!"
	fi

	for service in ./srcs/services/*.yaml; do
		kubectl apply -f  $service
	done
}

function main()
{
	#banner
	check_env
	setup_env
	handle_flags $@
	perform_actions
}

main $@
