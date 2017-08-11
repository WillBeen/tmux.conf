#!/bin/bash
# Ne pas diffuser hors PMU

# usefull puppet
export FACTERLIB=~/puppet/pmu_os_facts/lib/facter

# ssh connections
function cnx() {
#  tmux rename-window ${@%%.*}
  LANG=en_US.ISO-8859-15
  TERM=xterm
  args=$@
  prod=''
  if [[ ${args:4:3} == 'prd' ]] ; then
    prod='PROD '
  fi
#  printf '\033]2;%s\033\\' "${prod}${@%%.*}"
  ssh ${@%%.*}.adm.parimutuel.local
#  printf '\033]2;%s\033\\' $(hostname)
  LANG=en_US.UTF-8
  TERM=screen-256color
}
# ssh connections for AIX
function aix() {
  LANG=en_US.ISO-8859-15
  TERM=xterm
  cnx $@
  LANG=en_US.UTF-8
  TERM=screen-256color
}

# bac a sable developpement puppet
devpuppet="pfe-bas-appv1.adm.parimutuel.local"
alias cnxdevpuppet="cnx $devpuppet"
# rundeck production
rundeckprd="itc-prd-rbav1.adm.parimutuel.local"
alias cnxrundeckprd="cnx $rundeckprd"
# rundeck mutualise
rundeckmut="itc-mut-rbav1.adm.parimutuel.local"
alias cnxrundeckmut="cnx $rundeckmut"
# bac a sable rundeck (dev)
rundeckdev="gcf-dev-rbav1.adm.parimutuel.local"
alias cnxrundeckdev="cnx $rundeckdev"
# controleur neoload
itctstctrv1="itc-tst-ctrv1.adm.parimutuel.local"
neoloadctr="$itctstctrv1"
alias cnxitctstctrv1="cnx $itctstctrv1"
alias cnxneoloadctr="cnx $itctstctrv1"
# serveur nexus
nexus="itc-mut-refv1.adm.parimutuel.local"
alias cnxnexus="cnx $nexus"
# foreman
foremanmut='gcf-mut-prov1.adm.parimutuel.local'
alias cnxforemanmut="cnx $foremanmut"
foremanprd='gcf-prd-prov1.adm.parimutuel.local'
alias cnxforemanprd="cnx $foremanprd"
# puppet
puppetmasterprd="gcf-prd-appv1.adm.parimutuel.local"
alias cnxpuppetmasterprd="cnx $puppetmasterprd"
puppetmastermut="gcf-mut-appv1.adm.parimutuel.local"
alias cnxpuppetmastermut="cnx $puppetmastermut"
# satellite 6
satellite6="itc-mut-satv1.adm.parimutuel.local"
alias cnxsatellite6="cnx root@$satellite6"
