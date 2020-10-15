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
SRC=$BASEDIR/srcs
OBJ=$BASEDIR/obj

CLUSTER_PROPERTIES=$SRC/cluster-properties.txt
CLUSTER_AUTHENTICATION=$SRC/cluster-authentication.txt

export MINIKUBE_IN_STYLE=false # disable childish emoji

source $SRC/global_scripts/sed_i.sh # but POSIX ? couldn't be bothered !

case $KERNEL in
	Darwin)
		MINIKUBE_FLAGS+="--vm-driver=virtualbox --memory 4096 --cpus 4 --disk-size 40g"
		GOINFRE=/sgoinfre/sverschu/ 
		;;
	Linux)
		MINIKUBE_FLAGS+="--vm-driver=virtualbox --memory 4096 --cpus 4 --disk-size 40g"
		GOINFRE=~/goinfre
		;;
esac


DEPENDENCIES=(kubectl docker minikube wget)
function clean_up()
{
	case $1 in
		INT)
			logp fatal "aborting.."
		;;
		EXIT)
			tmp_delete $OBJ
			logp endsection
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

function klogs() {
	kubectl logs $(kubectl get pods | grep "$1" | grep -v "Terminating" | awk '{print $1}') || logp fatal "Couldn't provide logs for $1!"
}
function kattach() {
	kubectl exec -it $(kubectl get pods | grep "$1" | grep -v "Terminating" | awk '{print $1}') -- sh || logp fatal "Failed to attach to $1!"
}

function kdelete() {
	kubectl delete deployment $1; kubectl delete service $1; sleep 2; kubectl delete pod $(kubectl get pods | grep "$1" |  awk '{print $1}') --grace-period=0 --force || logp warning "Couldn't delete deployment/pod/service $1!"
}

function ft_services()
{
	# source : https://stackoverflow.com/questions/10551981/how-to-perform-a-for-loop-on-each-character-in-a-string-in-bash
	foo="ft-services"
	for (( i=0; i<${#foo}; i++ )); do
		clear
		l="${foo:$i:1}"
		zsh -c "banner $l"
		sleep 0.1
	done
	clear
}

function banner()
{
	clear
	IP="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
	printf "\e[1m\e[33m+-------------------------------------------------------------------------------------------+\n"
	printf "\e[1m\e[33m| \e[0m%-89s\e[1m\e[33m |\n" "`date`"
	printf "\e[1m\e[33m| %-89s\e[1m\e[33m |\n" ""
	printf "|\e[0m`tput bold` %-89s `tput sgr0`\e[1m\e[33m|\n" "ft_services @ $HOSTNAME"
	printf "\e[1m\e[33m+-------------------------------------------------------------------------------------------+\n"
	logp beginsection	
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
		if [ "${ARG}" == "launch" ]; then ACTION="launch"; break; fi
		if [ "${ARG}" == "post" ]; then ACTION="post"; break; fi
		if [ "${ARG}" == "stop" ]; then ACTION="stop"; break; fi
		if [ "${ARG}" == "get" ]; then ACTION="get"; break; fi
		if [ "${ARG}" == "add" ]; then ACTION="add"; break; fi
		if [ "${ARG}" == "purge" ]; then ACTION="purge"; break; fi
		if [ "${ARG}" == "clean" ]; then ACTION="clean"; break; fi
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

function tmp_create()
{
	logp info_nnl "Setting up working directory for variable insertion... "
	if [ ! -d $1 ] || [ -d $2 ]; then
		logp fatal "tmp_create expects a src and empty dst directory."
	else
		cp -r $1 $2
	fi
	echo "done!"
}

function tmp_insert_variables()
{
	if [ ! -d $1 ]; then logp fatal "tmp_insert_variables expects a working directory as argument"; fi;
	logp info_nnl "Inserting variables in working directory... "
	source $CLUSTER_PROPERTIES
	source $CLUSTER_AUTHENTICATION
	shopt -s dotglob
	find $1 -type f | while IFS= read -r file; do
		if [ "$(echo $file | grep .swp)" = "" ]; then
			while read -u 10 line; do
				var="$(echo $line | cut -d= -f1)"
				if [ $KERNEL = "Linux" ]; then	sed_i "s|__${var}__|${!var}|g" $file
				else							sed_i '' "s|__${var}__|${!var}|g" $file
				fi
			done 10<$CLUSTER_PROPERTIES
			while read -u 10 line; do
				var="$(echo $line | cut -d= -f1)"
				if [ $KERNEL = "Linux" ]; then	sed_i "s|__${var}__|${!var}|g" $file
				else							sed_i '' "s|__${var}__|${!var}|g" $file
				fi
			done 10<$CLUSTER_AUTHENTICATION
		fi
	done
	echo "done!"
}

function tmp_delete()
{
	logp info_nnl "Clearing out working directory... "
	if [ ! -d $1 ]; then
		echo  "N.A.";
		return
	else
		#if which srm 1>/dev/null; then
		#	srm -rf $1
		#else
		#	rm -rf $1
		#fi
		rm -rf $1
	fi
	echo "done!"
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
			tmp_create $SRC $OBJ
			tmp_insert_variables $OBJ
			source $CLUSTER_PROPERTIES
			
			logp info "Applying global configmap.."
			kubectl apply -k $OBJ || logp fatal "Couldn't apply global configmap.."
			if ! kubectl get serviceaccounts pod-service-access 2>/dev/null 1>&2; then
				logp info "Creating service account pod-service-access.."
				kubectl create serviceaccount pod-service-access || logp fatal "Couldn't add global serviceaccount for service listing.."
			fi
			if ! kubectl get serviceaccounts $CLUSTER_ADMIN 2>/dev/null 1>&2; then
				logp info "Creating service account $CLUSTER_ADMIN.."
				kubectl create serviceaccount $CLUSTER_ADMIN || logp fatal "Couldn't add global serviceaccount for dashboard.."
			fi
			kubectl apply -f $OBJ/pod-service-access-role-binding.yaml || logp fatal "Couldn't apply global service role-binding.."
			shopt -s dotglob
			find $OBJ/* -prune -type d | while IFS= read -r service_d; do
				if [[ $(basename $service_d) =~ ^[0-9] ]]; then
					if [ "$2" = "" ] || [ "$2" = "$(basename $service_d | cut -f2 -d-)" ]; then
						logp info "Starting $service_d..."
						sh $service_d/setup.sh || logp fatal "Couln't start $service_d..."
					fi
				fi
			done
			ACTION=post
			perform_actions
			return $?
		;;
		post)
			find $OBJ/* -prune -type d | while IFS= read -r service_d; do
				if [ -f $service_d/post.sh ]; then
					logp info "Running postscript for $service_d..."
					sh $service_d/post.sh
				fi
			done
			return $?
		;;
		launch)
			ACTION=start perform_actions
			ACTION=activate perform_actions
			return $?
		;;
		start)
			logp info "Firing up cluster..."
			case $KERNEL in
				Darwin)
					setup_env
					minikube_wrap start
					return $?
				;;
				Linux)
					setup_env
					minikube_wrap start
					return $?
				;;
			esac
			return $?
		;;
		stop)
			logp info "Stopping all cluster activity..."
			case $KERNEL in
				Darwin)
					setup_env
					minikube_wrap stop
					return $?
				;;
				Linux)
					setup_env
					minikube_wrap stop
					return $?
				;;
			esac
			return $?
		;;
		get)
			case $2 in
				admin)
					source $CLUSTER_AUTHENTICATION
					kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep $CLUSTER_ADMIN | awk '{print $1}')
				;;
			esac
			return $?
		;;
		add)
			case $2 in
				wireguard-peer)
					logp info_nnl "Adding wireguard peer.. "
					wireguard_add_peer $3 $4
				;;
			esac
			return $?
		;;
		purge)
			logp info "Purging..."
			case $KERNEL in
				Darwin)
					minikube delete
					rm -rf ~/.minikube ~/.kube
					rm -rf $GOINFRE/minikube
					rm -rf $GOINFRE/docker
					VBoxManage controlvm "minikube" poweroff 2>/dev/null 
					VBoxManage unregistervm --delete "minikube" 2>/dev/null
					return 0
				;;
				Linux)
					minikube_wrap stop
					rm -rf ~/.minikube
					rm -rf ~/.docker
					rm -rf ~/.kube
					VBoxManage controlvm "minikube" poweroff
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
			return $?
		;;
		clean)
			logp info "Cleaning..."
			case $KERNEL in
				Darwin)
					minikube_wrap delete
					return 0
				;;
				Linux)
					minikube_wrap delete
					return 0
			esac
			return $?
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
				if [ ! -d $GOINFRE/docker ] || [ ! -L ~/Library/Containers/com.docker.docker ]
				then
					logp info "Setting up Docker folder @ $GOINFRE/docker!"
					rm -rf ~/Library/Containers/com.docker.docker
					mkdir $GOINFRE/docker
					ln -s $GOINFRE/docker ~/Library/Containers/com.docker.docker
				fi
				if [ ! -d $GOINFRE/minikube ] || [ ! -L ~/.minikube ]
				then
					logp info "Setting up Minikube folder @ $GOINFRE/minikube!"
					rm -rf ~/.minikube
					mkdir $GOINFRE/minikube
					ln -s $GOINFRE/minikube ~/.minikube
				fi
				#logp info "Starting docker..."	
				#open -a Docker
				#while :
				#do
				#	if docker version 1>/dev/null 2>&1; then
				#		break
				#	else
				#		sleep 1
				#	fi
				#done
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
				minikube start $MINIKUBE_FLAGS || logp fatal "Failed to start minikube.."
				eval $(minikube docker-env)
				return $?
			fi
		;;
		stop)
			if minikube status 2>/dev/null 1>/dev/null; then
				minikube stop || logp fatal "Failed to stop minikube.."
				return $?
			fi
		;;
		delete)
			minikube delete
		;;
	esac
}

function zsh_insert_functions()
{
cat << EOF >> ~/.zshrc
# Kubernetes
function klogs() {
	kubectl logs $(kubectl get pods | grep "$1" | grep -v "Terminating" | awk '{print $1}')
}
function kattach() {
	kubectl exec -it $(kubectl get pods | grep "$1" | grep -v "Terminating" | awk '{print $1}') -- sh
}
EOF
}

function main()
{
	banner
	check_env
	handle_flags $@
	perform_actions $@
}

main $@
