# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/tmux.conf:/usr/local/bin:/opt/homebrew/opt/ncurses/bin:/opt/homebrew/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/Frx25570/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy/mm/dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
plugins=(git git-flow brew history node npm kubectl)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export sshagentfile=/tmp/sshagentfile
function killSSHagents {
  for process in `ps -ef | grep ssh-agent | grep -v grep | awk '{print $2}'` ; do
    kill $process
  done
  rm -f ${sshagentfile}
}

# Starts and initialize ssh agent if not yet started
# Attaches it to the session if already running
function startSSHagent {
  if [[ -f ${sshagentfile} ]] ; then
    for var in `cat ${sshagentfile}` ; do
      export ${var}
    done
  else
    killSSHagents
    eval `ssh-agent`
    ssh-add ~/.ssh/foncia/gitlab.rsa
    env | grep SSH > ${sshagentfile}
  fi
}

# Adds or replaces an AWS profile in ~/.aws/credentials
function setAWSprofile {
  aws_profile=$1
  tmpfile=`mktemp`
  awk '!/\['${aws_profile}']/' RS="\n\n" ORS="\n\n" ~/.aws/credentials > ${tmpfile}
  mv ${tmpfile} ~/.aws/credentials
  read -s -d '`' creds
  echo ${creds} | sed 's/ *\[.*]/['${aws_profile}']/g' >> ~/.aws/credentials
  echo -e "Verifying AWS profile"
  aws sts --profile ${aws_profile} get-caller-identity | cat
}

function awsprofiles {
  profiles=()
  ls terraform.*.tfvars | awk -F '.' '{print NR " : " $2}'
  read -k 1 -s choice
  env=$(ls terraform.*.tfvars | awk -F '.' '{if (NR=='${choice}') print $2}')

  ls terraform.${env}.tfvars >/dev/null 2>&1 || (echo "bad value !" ; exit 1) || return 1

  profiles+=($(egrep "profile *= *\"" terraform.${env}.tfvars | cut -d '"' -f 2))
  egrep "profile *= *\"" *.tf | cut -d '"' -f 2 | while read -r profile ; do
    profiles+=(${profile})
  done

  for profile in ${profiles[@]} ; do
    echo -e "\nCopy credentials (option 2) for profile : ${profile}\n(Validate by entering backquote key : \` )"
    setAWSprofile $profile
  done

  tmp_cred=$(mktemp)
  cat -s ~/.aws/credentials > ${tmp_cred}
  mv ${tmp_cred} ~/.aws/credentials
}

alias unassumeRole="for var in \$(env | grep '^AWS_' | cut -f"1" -d'=') ; do unset \$var ; done"

function createvirtualenv {
  python3 -m venv ~/pythonenvs/$1
}
function deletevirtualenv {
  rm -rf ~/pythonenvs/$1
}
alias listvirtualenvs="ls ~/pythonenvs"
function loadvirtualenv {
  echo "loading Python virtual env : $1"
  source ~/pythonenvs/$1/bin/activate
}

alias pip=pip3
function plan {
  ./launch.sh plan $@
}
function apply {
  ./launch.sh apply $@
}
function init {
  ./launch.sh init $@
}

export ciexpand_py_virtual_env="terraform"
function ciexpand {
    loadvirtualenv ${ciexpand_py_virtual_env} > /dev/null
    expand_gitlab-ci.py
    deactivate
}
function cilocal {
  # expand .gitlab-ci.yml
  export base_dir="/Users/Frx25570/Documents/gitrepos/"
  cp .gitlab-ci.yml .gitlab-ci.yml.svg
  if [[ "$(yq '.include' .gitlab-ci.yml)" != "null" ]] ; then
    expand=true
    else
    expand=false
  fi
  if ${expand} ; then
    echo "## expanding .gilab-ci.yml ##"
    template_project=$(yq -r '.include[0].project' .gitlab-ci.yml)
    template_branch=$(yq '.variables.TEMPLATE_CI_VERSION' .gitlab-ci.yml | cut -d '"' -f 2)
    this_dir=$(pwd)
    cd "${base_dir}${template_project}"
    git checkout ${template_branch} > /dev/null 2>&1
    cd ${this_dir}
    ciexpand
    # loadvirtualenv ${ciexpand_py_virtual_env} > /dev/null
    # expand_gitlab-ci.py
    # deactivate
    echo "## .gilab-ci.yml has been expanded ##"
  fi

  temp_commit_msg="temp commit for cilocal"
  # check if something to commit
  if [ -n "$(git status --porcelain)" ]; then
    git add . >/dev/null 2>&1
    git commit -m "${temp_commit_msg}" >/dev/null 2>&1
    git add . >/dev/null 2>&1
    git commit -m "${temp_commit_msg}" >/dev/null 2>&1
  fi

  # list all jobs and runs selected one
  i=0
  jobs=()
  for job in $(yq -r 'to_entries[] | select(.value | type == "object") | select(.value | has("stage")) | .key' .gitlab-ci.yml) ; do
  # for job in $(yq -r 'keys[] | select(match("^syntax-.*")) | .' .gitlab-ci.yml) $(yq -r 'keys[] | select(match("^deploy-.*")) | .' .gitlab-ci.yml) ; do
    if [[ "${job:0:1}" != "." ]] ; then
      jobs+=($job)
      i=$(($i+1))
      echo $i : $job
    fi
  done
  read jobnum
  job_name=${jobs[${jobnum}]}
  gitlab-runner exec docker "${job_name}"

  # remove temp commit
  if $(git show HEAD | grep -q "${temp_commit_msg}") ; then git reset --mixed HEAD~1 >/dev/null 2>&1 ; fi
  
  if ${expand} ; then
    # restore .gitlab-ci.yml
    # cp .gitlab-ci.yml .gitlab-ci.yml.pouet.yml
    mv .gitlab-ci.yml.svg .gitlab-ci.yml
  fi
}

function change_tf_version {
  rm ~/bin/terraform
  ln -s ~/bin/terraform_$1 ~/bin/terraform
  terraform --version
}
alias tf013="change_tf_version '0.13.7'"
alias tf1="change_tf_version '1.1.6'"


alias tf_0-12-29="change_tf_version '0.12.29'"
alias tf_0-12-31="change_tf_version '0.12.31'"
alias tf_0-14-11="change_tf_version '0.14.11'"
alias tf_1-0-7="change_tf_version '1.0.7'"
alias tf_1-0-8="change_tf_version '1.0.8'"
alias tf_1-0-11="change_tf_version '1.0.11'"

# format and document terraform project with pre-commit
alias precommit=".git/hooks/pre-commit"

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# Oh-my-zsh theme
#source ~/zsh_external_themes/alien/alien.zsh
source ~/.antigen/bundles/eendroroy/alien/alien.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/david.delgado/tmp/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/david.delgado/tmp/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/david.delgado/tmp/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/david.delgado/tmp/google-cloud-sdk/completion.zsh.inc'; fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# modules
source /opt/homebrew/share/antigen/antigen.zsh

if [[ -f "$HOME/.okta/bash_functions" ]]; then
    . "$HOME/.okta/bash_functions"
fi
if [[ -d "$HOME/.okta/bin" && ":$PATH:" != *":$HOME/.okta/bin:"* ]]; then
    PATH="$HOME/.okta/bin:$PATH"
fi

# alias gcl='gitlab-ci-local'
# gitlab-ci-local --completion 

# start SSH agent
startSSHagent

