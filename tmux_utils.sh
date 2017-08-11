#!/bin/bash

function split-pane() {
  # recuperation du titre du pane source
  title=$(tmux display-message -p '#T')
  # si le titre est le hostname du serveur tmux, on fait un split simple
  if [[ $title == `hostname` ]] ; then
    tmux split-window $1 -c '#{pane_current_path}'
  else
    # recuperation :
    #   - de l'utilisateur de connexion
    #   - du serveur ssh
    #   - du pwd
    user=${title%%@*}
    str=${title:${#user}+1}
    host=${str%%:*}
    curdir=${str##*:}
    tmux split-window $1 ". ~/tmux.conf.d/specific_pmu.sh ; cnx ${host}"
  fi
}
split-pane $1
