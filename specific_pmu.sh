#!/bin/bash
# Ne pas diffuser hors PMU

# usefull puppet
export FACTERLIB=~/puppet/pmu_os_facts/lib/facter
# bac a sable developpement puppet
devpuppet="gcf-dev-appv1"
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
puppetmasterprd3="gcf-prd-appv1"
alias cnxpuppetmasterprd3="cnx $puppetmasterprd3"
puppetmasterprd4="gcf-prd-appv2"
alias cnxpuppetmasterprd4="cnx $puppetmasterprd4"
puppetmastermut3="gcf-mut-appv1"
alias cnxpuppetmastermut3="cnx $puppetmastermut3"
puppetmastermut4="gcf-mut-appv2"
alias cnxpuppetmastermut4="cnx $puppetmastermut4"
# packercloudmut="gcf-mut-cldv1.adm.parimutuel.local"
cloudmut="gcf-mut-cldv1"
alias cnxcloudmut="cnx $cloudmut"

# serveur de rebond pour aller sur les serveurs sur AWS
export REBOND_AWS=gcf-mut-cldv1.adm.parimutuel.local

# ssh connections
function cnx() {
  LANG=en_US.ISO-8859-15
  args=`echo $@ | awk 'BEGIN {FS="@"} {if (NF >= 2 )print $(NF-1)"@"$NF ; else print "'$(whoami)'@"$NF}'`
  if [[ ( ${args:11:1} == 'v' || ${args:11:1} == 'w' ) && ! ( $args =~ .+@.+ ) ]] ; then
    panename="\033]2;${args}\033\\"
    printf $panename
    key_string="`cat ~/.ssh/id_rsa.pub`"
    key="`cat ~/.ssh/id_rsa.pub | cut -d " " -f 2`"
    old_key="`cat ~/.ssh/id_rsa.pub.old | cut -d " " -f 2`"
    clear
    ssh -A -o PasswordAuthentication=no $args
    if [[ $? == 255 ]] ; then
      ssh -A $args "[ -d ~/.ssh ] || mkdir ~/.ssh ; chmod 750 ~/.ssh ; grep ${key} ~/.ssh/authorized_keys 1>/dev/null 2>&1 || echo '${key_string}' >> ~/.ssh/authorized_keys ; sed -i '\:${old_key}:d' ~/.ssh/authorized_keys"
      clear ; ssh -A $args -o PasswordAuthentication=no
    fi
  else
    panename="\033]2;${args}\033\\"
    printf $panename
    key_string="`cat ~/.ssh/id_rsa.pub`"
    key="`cat ~/.ssh/id_rsa.pub | cut -d " " -f 2`"
    old_key="`cat ~/.ssh/id_rsa.pub.old | cut -d " " -f 2`"
    #TERM=xterm
    clear
    ssh -A -o PasswordAuthentication=no $args
    if [[ $? == 255 ]] ; then
      ssh -A $args "[ -d ~/.ssh ] || mkdir ~/.ssh ; chmod 750 ~/.ssh ; grep ${key} ~/.ssh/authorized_keys 1>/dev/null 2>&1 || echo '${key_string}' >> ~/.ssh/authorized_keys ; sed -i '\:${old_key}:d' ~/.ssh/authorized_keys"
      clear ; ssh -A $args -o PasswordAuthentication=no
    fi
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
