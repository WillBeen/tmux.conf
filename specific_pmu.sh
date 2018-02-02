#!/bin/bash
# Ne pas diffuser hors PMU

# usefull puppet
export FACTERLIB=~/puppet/pmu_os_facts/lib/facter

# bac a sable developpement puppet
devpuppet="pfe-bas-appv1"
alias cnxdevpuppet="cnx $devpuppet"
# rundeck production
rundeckprd="itc-prd-rbav1"
alias cnxrundeckprd="cnx $rundeckprd"
# rundeck mutualise
rundeckmut="itc-mut-rbav1"
alias cnxrundeckmut="cnx $rundeckmut"
# bac a sable rundeck (dev)
rundeckdev="gcf-dev-rbav1"
alias cnxrundeckdev="cnx $rundeckdev"
# controleur neoload
itctstctrv1="itc-tst-ctrv1"
neoloadctr="$itctstctrv1"
alias cnxitctstctrv1="cnx $itctstctrv1"
alias cnxneoloadctr="cnx $itctstctrv1"
# serveur nexus
nexus="itc-mut-refv1"
alias cnxnexus="cnx $nexus"
# foreman
foremanmut='gcf-mut-prov1'
alias cnxforemanmut="cnx $foremanmut"
foremanprd='gcf-prd-prov1'
alias cnxforemanprd="cnx $foremanprd"
# puppet
puppetmasterprd="gcf-prd-appv1"
alias cnxpuppetmasterprd="cnx $puppetmasterprd"
puppetmastermut="gcf-mut-appv1"
alias cnxpuppetmastermut="cnx $puppetmastermut"
puppetv4mut="gcf-mut-appv2"
alias cnxpuppetv4mut="cnx $puppetv4mut"
# packercloudmut="gcf-mut-cldv1.adm.parimutuel.local"
cloudmut="gcf-mut-cldv1"
alias cnxcloudmut="cnx $cloudmut"

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
  # connexion via rebond rundeck prd pour acces lecture seule sur serveurs de production
  elif [[ ${args:3:5} == "-prd-" && ! ( $args =~ ${rundeckprd}.*  || ${args:0:3} == gcf ) ]] ; then
    ssh -t $rundeckprd sudo -iu rundeck ssh $args
  # connexion via rebond cloud pour amazon
  elif [[ $args =~ ip-.*-.*-.*-.* ]] ; then
    tmp=${args//-/.}
    clear ; ssh -t ${REBOND_AWS} ssh -i .ssh/aws.pem ec2-user@${tmp:3}
  elif [[ ( ${args:11:1} == 'v' || ${args:11:1} == 'w' ) && ! ( $args =~ .+@.+ ) ]] ; then
    panename="\033]2;$(whoami)@${args}\033\\"
    printf $panename
    clear ; ssh $args
  else
    panename="\033]2;$(whoami)@${args}\033\\"
    printf $panename
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
