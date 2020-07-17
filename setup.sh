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
BASEDIR="$(dirname $0)"
SRCS_DIR=$BASEDIR/srcs
GLOB_VAR_FILE=$SRCS_DIR/build-variables.txt

export MINIKUBE_IN_STYLE=false # disable childish emoji

case $KERNEL in
	Darwin)
		MINIKUBE_FLAGS+=--vm-driver=virtualbox
		;;
	Linux)
		#MINIKUBE_FLAGS+=--vm-driver=virtualbox
		;;
esac


DEPENDENCIES=(docker kubectl minikube helm)
function clean_up()
{
	case $1 in
		INT)
			logp fatal "aborting.."
		;;
		EXIT)
			tmp_delete yaml
			tmp_delete sh
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
		info_nnl)
			zsh -c "echo -n -e \"\e[32m\e[1m* \e[0m$2\""
			;;
		warning)
			zsh -c "echo -e \"\033[31m\e[1m* \e[0m$2\""
			;;
		warning_nnl)
			zsh -c "echo -n -e \"\033[31m\e[1m* \e[0m$2\""
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
		if [ "${ARG}" == "activate" ]; then ACTION="activate"; break; fi
		if [ "${ARG}" == "post" ]; then ACTION="post"; break; fi
		if [ "${ARG}" == "update" ]; then ACTION="update"; break; fi
		if [ "${ARG}" == "stop" ]; then ACTION="stop"; break; fi
		if [ "${ARG}" == "get" ]; then ACTION="get"; break; fi
		if [ "${ARG}" == "add" ]; then ACTION="add"; break; fi
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

function file_update()
{
	source $1
	basedir=$(dirname "$1")
	i=0
	for src in ${srcs[@]}; do
		name=${names[i]}; i=$((i + 1))
		wget -O $basedir/$name.yaml.new $src 1>/dev/null 2>&1 || return 1
		if ! diff $basedir/$name.yaml $basedir/$name.yaml.new 1>/dev/null; then
			echo;logp warning_nnl "New version for $name.. continue and show diff? y/n : "; read yn </dev/tty
			if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
				diff $basedir/$name.yaml $basedir/$name.yaml.new
				echo;logp warning_nnl "Continue update? y/n : "; read yn </dev/tty; echo
				if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
					mv $basedir/$name.yaml.new $basedir/$name.yaml && rm -f $basedir/$name.yaml.new
				else
					rm -f $basedir/$name.yaml.new
				fi
			fi
		else
			printf "No update available for $name. "
			rm -f $basedir/$name.yaml.new
		fi
	done
	echo
}

function tmp_create()
{
	if [ "$1" = "" ]; then logp fatal "expecting extension."; fi; ext=$1
	shopt -s dotglob
	find $SRCS_DIR/* -prune -type d | while IFS= read -r service_d; do
		for file in $service_d/*.$ext; do
			basename="$(basename $file)"
			cp $file $service_d/tmp_$basename
		done
	done
}

function tmp_insert_variables()
{
	if [ "$1" = "" ]; then logp fatal "expecting extension."; fi; ext=$1
	source $GLOB_VAR_FILE
	shopt -s dotglob
	find $SRCS_DIR -type f -name "tmp_*.$ext" | while IFS= read -r file; do
		basename="$(basename $file)"
		for line in $(cat $GLOB_VAR_FILE); do
			var="$(echo $line | cut -d= -f1)"
			sed -i '' s/__${var}__/${!var}/g $file
		done
	done
}

function tmp_delete()
{
	if [ "$1" = "" ]; then logp fatal "expecting extension."; fi; ext=$1
	shopt -s dotglob
	find $SRCS_DIR/* -prune -type d | while IFS= read -r service_d; do
		for file in $service_d/*.$ext; do
			basename="$(basename $file)"
			rm -f $service_d/tmp_$basename
		done
	done
}

function wireguard_add_peer()
{
	if [ "$1" == "" ] || [ "$2" == "" ]; then
		logp fatal "No allowed ip's CIDR and key specified.."
	fi
cat <<'EOF' | kubectl apply -f -
apiVersion: kilo.squat.ai/v1alpha1
kind: Peer
metadata:
  name: squat
spec:
  allowedIPs:
  - $1
  publicKey: $2
  persistentKeepalive: 10
EOF
	if [ $? -eq 0 ]; then
		logp info "Succesfully added peer."
	else
		logp fatal "Couldn't add peer."
	fi
}

function perform_actions()
{
	case $ACTION in
		activate)
			tmp_create yaml
			tmp_insert_variables yaml
			kubectl apply -k $SRCS_DIR || logp fatal "Couldn't apply global configmap.."
			shopt -s dotglob
			find $SRCS_DIR/* -prune -type d | while IFS= read -r service_d; do
				logp info "Starting $service_d..."
				sh $service_d/setup.sh
			done
		;;
		post)
			find $SRC_DIR/* -prune -type d | while IFS= read -r service_d; do
				if [ -f $service_d/post.sh ]; then
					logp info "Running postscript for $service_d..."
					sh $service_d/post.sh
				fi
			done
		;;
		start)
			logp info "Starting..."
			setup_env
			minikube_wrap start
			return $?
		;;
		stop)
			logp info "Stopping..."
			minikube_wrap stop
			return $?
		;;
		update)
			shopt -s dotglob
			find $SRC_DIR/* -prune -type d | while IFS= read -r service_d; do
				logp info_nnl "Checking for updates for $service_d..."
				file_update $service_d/update.sh
			done
		;;
		get)
			case $2 in
				admin)
					kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
				;;
			esac
		;;
		add)
			case $2 in
				wireguard-peer)
					logp info_nnl "Adding wireguard peer.. "
					wireguard_add_peer $3 $4
				;;
			esac
		;;
		purge)
			logp info "Purging..."
			case $KERNEL in
				Darwin)
					minikube_wrap stop
					minikube delete
					rm -rf ~/goinfre/minikube
					rm -rf ~/goinfre/docker
					VBoxManage controlvm "minikube" poweroffip 2>/dev/null 
					VBoxManage unregistervm --delete "minikube" 2>/dev/null
					return 0
				;;
				Linux)
					minikube_wrap stop
					rm -rf ~/.minikube
					rm -rf ~/.docker
					rm -rf ~/.kube
					VBoxManage controlvm "minikube" poweroffip
					VBoxManage unregistervm --delete "minikube"
					minikube delete
					sudo kubeadm reset
					sudo rm -rf /var/lib/minikube
					sudo rm -rf /var/lib/kubelet
					sudo rm -rf /var/lib/localkube
					sudo rm -rf /data/minikube
					sudo rm -rf /var/lib/kubeadm.yaml
					return 0
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
			if ! docker version 1>/dev/null 2>&1; then
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
				logp info "Starting docker..."	
				open -a Docker
				while :
				do
					if docker version 1>/dev/null 2>&1; then
						break
					else
						sleep 1
					fi
				done
			fi
		;;
	esac
	minikube config set WantUpdateNotification false # disable annoying warning
	export MINIKUBE_IN_STYLE=false # disable childish emoji
}

function minikube_wrap()
{
	case $1 in
		start)
			if ! minikube status 2>/dev/null 1>/dev/null; then
				minikube start $MINIKUBE_FLAGS
				eval $(minikube docker-env)
				return $?
			fi
		;;
		stop)
			if minikube status 2>/dev/null 1>/dev/null; then
				minikube stop
				return $?
			fi
		;;
	esac
}

function main()
{
	#banner
	check_env
	handle_flags $@
	perform_actions $@
}
main $@
