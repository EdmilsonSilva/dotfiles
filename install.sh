#!/usr/bin/env bash
# check if .env file exists
if [ ! -f .env ]; then
  echo ".env file does not exist. Please create it and set the sensitive data."
  exit 1
fi

# true if DOTFILES_PATH is not set
if [ -z ${DOTFILES_PATH} ]; then
  echo "setting up bash and aliases"
  
  function source_file(){
      echo "
  if [ -f \$DOTFILES_PATH/$1 ]; then
      . \$DOTFILES_PATH/$1
  fi" >> ~/.bashrc
  }

  # add dotfiles folder path to a var
  echo "export DOTFILES_PATH=$PWD" >> ~/.bashrc

  # add source of files on bashrc

  source_file .bashaliasrc
  source_file .bashexportsrc
  source_file .bashrc

  # source ~/.bashrc
  echo "Please Restart you terminal for the changes to take effect. Or you can run `source ~/.bashrc`"
  
fi

if [ -f .env ]; then
  echo "Reading, now your sensitive data from .env file. (please does not includes the bank acount #, neither you password for fort knox)"
  set -o allexport
  source .env set
  set +o allexport
  envVarNames=()
  i=0
  while read line; do
    envVarNames[$i]=$(echo $line | cut -d "=" -f 1)
    i=$i+1
  done < .env

  filesToSubstituteEnvs=(".wakatime.cfg" ".gitconfig")
  # create backups and execute for all files
  for file in ${filesToSubstituteEnvs[@]}; do
    
    cp "./$file" "./$file.bkp"  
    for str in ${envVarNames[@]}; do
      sed -i "s/\${$str}/${!str}/g" $file
    done
    cp "./$file" ~/
    mv "./$file.bkp" "./$file"
  done
else
  echo "Please copy the .env-default file and input the sensitive data there."
fi

if ! command -v git &> /dev/null; then
  echo 'Installing git'
  sudo apt install git -y
fi
echo "git version => $(git --version)"

# installing net-tools
if ! command -v ifconfig &> /dev/null; then
  echo 'Installing net-tools'
  sudo apt install net-tools -y
fi
echo "net-tools version => $(ifconfig --version)"

# installing jq
if ! command -v jq &> /dev/null; then
  echo 'Installing jq'
  sudo apt install jq -y
fi
echo "JQ version => $(jq --version)"

# installing fzf
if ! command -v fzf &> /dev/null; then
  echo 'Installing fzf'
  sudo apt install fzf -y
fi
echo "fzf version => $(fzf --version)"

# installing python
if ! command -v python3 &> /dev/null; then
  echo 'Installing python3'
  sudo apt update
  sudo apt install python3-dev python3-pip python3-setuptools -y
  pip3 install thefuck --user
fi
echo "python3 version => $(python3 --version)"

if [ -z ${NVM_DIR} ]; then
  nvmLatestVersion=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')
  echo "Installing nvm on version: $nvmLatestVersion"

  curl -sL "https://raw.githubusercontent.com/nvm-sh/nvm/$nvmLatestVersion/install.sh" -o install_nvm.sh
  bash install_nvm.sh
  rm install_nvm.sh

  export NVM_DIR="$HOME/.nvm"
fi

if ! [ -z ${NVM_DIR} ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
echo "nvm version => $(nvm --version)"


if ! [ -z ${NVM_DIR} ]; then
  if ! command -v node &> /dev/null; then
    nvm install --lts
    nodeVersionInstalled=$(nvm --version)
    echo "Node version $nodeVersionInstalled installed"
  fi
fi

if ! command -v rg &> /dev/null; then
  echo 'Installing ripgrep'
  sudo apt install ripgrep
fi

if ! command -v fd &> /dev/null; then
  echo 'Installing fd'
  sudo apt install fd-find
fi

echo "Node version => $(node --version)"

sh ./install_nvim.sh

if ! command -v i3 &> /dev/null; then
  echo 'Installing i3'
  sudo apt install i3 -y
fi

echo 'Configuring i3 and creating symlink'
# check if .config/nvim folder exists before creating symlink
if [ -d ~/.config/i3 ]; then
  mv ~/.config/i3{,.bkp}
fi

# check if .config/nvim still exists, if not create symlink
if [ ! -a ~/.config/i3 ]; then
  ln -s $DOTFILES_PATH/i3 $HOME/.config/i3
fi

echo "bye"
