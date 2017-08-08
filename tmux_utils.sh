function split-pane() {
  h=$(tmux display-message -p '#T')
  if [[ ${h:0:4} == 'PROD' ]] ; then
    h=${h:4}
    prod='PROD '
  fi
  if [[ $h != `hostname` ]] ; then
    tmux split-window $1 -c '#{pane_current_path}' "printf '\033]2;%s\033\\' '${prod}${h}'; ssh $h"
  else
    tmux split-window $1 -c '#{pane_current_path}'
  fi
}
split-pane $1
