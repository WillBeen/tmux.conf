#!/bin/bash
# Ne pas diffuser hors PMU

# usefull puppet
export FACTERLIB=~/puppet/pmu_os_facts/lib/facter

# serveur de rebond pour aller sur les serveurs sur AWS
export REBOND_AWS=gcf-mut-cldv1.adm.parimutuel.local

# ssh connections
function cnx() {
#  tmux rename-window ${@%%.*}
  LANG=en_US.ISO-8859-15
  args=$@
  if [[ $args =~ 10\.21[23456]\..*\..* ]] ; then
    panename="\033]2;$(whoami)@${args}\033\\"
    printf $panename
    clear ; ssh -t ${REBOND_AWS} ssh -i .ssh/aws.pem ec2-user@${args}
  elif [[ $args =~ ip-.*-.*-.*-.* ]] ; then
    tmp=${args//-/.}
    clear ; ssh -t ${REBOND_AWS} ssh -i .ssh/aws.pem ec2-user@${tmp:3}
  elif [[ ( ${args:11:1} == 'v' || ${srv:11:1} == 'w' ) && ! ( $args =~ .+@.+ ) ]] ; then
    panename="\033]2;$(whoami)@${args}\033\\"
    printf $panename
    clear ; ssh $args
  else
    TERM=xterm
    clear ; ssh $args
  fi
  LANG=en_US.UTF-8
  TERM=screen-256color
  pane-rename
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
puppetv4mut="gcf-mut-appv2.adm.parimutuel.local"
alias cnxpuppetv4mut="cnx $puppetv4mut"
# packercloudmut="gcf-mut-cldv1.adm.parimutuel.local"
cloudmut="gcf-mut-cldv1.adm.parimutuel.local"
alias cnxcloudmut="cnx $cloudmut"

