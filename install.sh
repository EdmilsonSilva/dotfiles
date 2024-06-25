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

# installing docker
if ! command -v docker &> /dev/null; then
  echo 'Installing docker'
  sudo addgroup --system docker
  sudo usermod -aG docker $USER
   sudo usermod -aG docker root
  sudo snap install docker
  sudo chown $USER:docker /var/run/docker.sock
fi
echo "docker version => $(docker version)"
echo "docker version => $(docker compose version)"

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

# installing kubectl
if ! command -v kubectl &> /dev/null; then
  echo 'Installing kubectl'
  sudo snap install kubectl --classic
fi
echo "kubectl version => $(kubectl version --client)"
sudo cp config/* ~/
echo "kubectl set context (staging-shared)"
kubectl config set-context --current --namespace=staging-shared
echo "kubectl list pods"
kubectl get pods

# installing slack
echo 'Installing slack'
sudo snap install slack
# installing postman
echo 'Installing postman'
sudo snap install postman

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

# installing java
if ! command -v java &> /dev/null; then
  echo 'Installing java'
  sudo apt update
  sudo apt install openjdk-17-jdk openjdk-17-jre -y
fi
echo "java version => $(java -version)"

# installing maven
if ! command -v mvn &> /dev/null; then
  echo 'Installing maven'
  sudo apt install maven -y
fi
echo "maven version => $(mvn -version)"

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

if ! command -v go &> /dev/null; then
  echo 'Installing go'
  wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
  rm -rf go1.22.4.linux-amd64.tar.gz
fi
echo "go version => $(go version)"

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
sh ./install_i3.sh

echo "bye"
