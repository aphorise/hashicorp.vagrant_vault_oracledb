#!/bin/bash
# // libraries needed by HSM CP5 simulator
HSM_DEPS='' ;  # 'glibc.i686 libgcc.i686 libstdc++.i686' ;

if ! wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --quiet 1>&2 > /dev/null ; then printf 'ERROR: installing epel.\n' ; fi ;
if ! rpm --quiet -ivh epel-release-latest-7.noarch.rpm 1>&2 > /dev/null ; then printf 'ERROR: installing epel.\n' ; fi ;

yum -y -q --nogpgcheck update ;
#yum -y -q --nogpgcheck groups mark convert  # HSM
#yum -y -q --nogpgcheck groupinstall "Development Tools" ;  # HSM
#yum -y -q --nogpgcheck install epel-release && yum -y -q --nogpgcheck update ;
yum -y -q --nogpgcheck install ${HSM_DEPS} glances nano htop nload unzip jq sosreport psmisc ;  # HSM: net-tools wget opensc

# // .bashrc profile alias and history settings.
cat >> /home/vagrant/.bashrc <<EOL
SHELL_SESSION_HISTORY=0
export HISTSIZE=1000000
export HISTFILESIZE=100000000
export HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
alias nano="nano -c"
alias grep="grep --color=auto"
alias ls="ls --color=auto"
alias dir="dir --color=auto"
alias reset="reset; stty sane; tput rs1; clear; echo -e \\"\033c\\""
alias jv="sudo journalctl -u vault.service --no-pager -f --output cat"
alias jreset="sudo journalctl --since now && sudo journalctl --vacuum-time=1s"
PS1="\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] "

export CLIENT_HOME=/usr/lib/oracle/19.9/client64
export LD_LIBRARY_PATH=${CLIENT_HOME}/lib
export PATH=\$PATH:${CLIENT_HOME}/bin
EOL

#printf "${sBASH_DEFAULT}" >> ~/.bashrc ; #if [[ $(logname) != $(whoami) ]] ; then printf "${sBASH_DEFAULT}" >> /home/$(logname)/.bashrc ; fi ;
find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> /home/vagrant/.nanorc
printf 'BASH: defaults in (.bashrc) profile set.\n' ;

printf """
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

${IPDB} db.test db
${IPV} vault.test vault1
""" > /etc/hosts