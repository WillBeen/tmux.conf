# .bashrc

# prise en compte des touches ctrl + arrow
# besoin de cocher PuTTY > Terminal > Features > Disable Application cursor keys mode
export TERM=screen-256color

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH="$PATH:/usr/java/latest/bin"

# User specific aliases and functions
alias l='ls -lisa --color'

# edit and reload .bashrc
alias rldbashrc='. ~/.bashrc'
alias edbashrc='vi ~/.bashrc ; rldbashrc'
alias catbashrc='cat ~/.bashrc'
alias edspecific='vi ~/tmux.conf.d/specific_pmu.sh ; rldbashrc'

# edit and reload .vimrc
alias rldvimrc='. ~/.vimrc'
alias edvimrc='vi ~/.vimrc ; rldvimrc'

# lancement de tmux attach si sessions existantes
function tmu() {
  tput smkx
  tmux list-sessions > /dev/null
  if [ $? -eq 0 ] ; then
    tmux attach $@
  else
    tmux $@
  fi
  clear
  tmux show-buffer
  read
  # lance tmux en boucle et affiche le buffer
  while true ; do
    tmux attach
    # clear du terminal (y compris le scrollback)
    clear
    printf '\033[3J'
    tmux show-buffer
    read
  done
}
# reload reload .tmux.conf
alias rldtmux='tmux source-file ~/.tmux.conf'
alias edtmux='vi ~/.tmux.conf ; rldtmux'

# specific boulot
. ~/tmux.conf.d/specific_pmu.sh
# edit cloud known hosts
alias cloud_known_hosts="vim scp://gcf-mut-cldv1.adm.parimutuel.local//home/p093770/.ssh/known_hosts"

# usefull puppet
export PUPPET_PATH=~/puppet
alias cdpuppet='cd $PUPPET_PATH'
alias pupcheckdbg='sudo puppet apply --modulepath="$PUPPET_PATH" --parser=future $1 --test --debug --noop'
alias pupcheck='sudo puppet apply --modulepath="$PUPPET_PATH" --parser=future $1  --noop'
alias pupa='sudo puppet apply --modulepath="$PUPPET_PATH" --parser=future $1'
alias puplint='puppet-lint $2 --no-autoloader_layout-check --no-class_inherits_from_params_class-check --no-80chars-check --no-140chars-check --fail-on-warnings --no-variable_scope-check --no-only_variable_string-check $1'
alias puplintall='find . -name *.pp | while read -r i; do echo $i; puplint $i --fix;done'

# usefull git
# git log as a graph
alias gitgraph="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all "


# affichage des couleurs
function colors() {
  for i in {0..255}; do
  printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}
# decoupage de panneau tmux avec memorisation du host
function split-pane() {
  h=$(tmux display-message -p '#T')
  tmux split-window $1 -c '#{pane_current_path}' "printf '\033]2;%s\033\\' '$h'; ssh $h"
}
function split-pane-horizontal() {
  split-pane -h
}
function split-pane-vertical() {
  split-pane -v
}
# renomme la fenetre rmux courante avec le hostname
alias window-rename="tmux rename-window"
function pane-rename {
  args=$@
  h=$(hostname)
  printf '\033]2;%s\033\\'  ${args:-$h}
}
