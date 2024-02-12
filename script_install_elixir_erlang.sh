#!/bin/bash

# Função para verificar se um comando está disponível
command_exists() {
  # Verifica se o comando está disponível
  command -v "$1" >/dev/null 2>&1
}

# Verificar se todas as dependências estão instaladas
check_dependencies() {
  echo "Verificando se todas as ferramentas necessárias estão instaladas..."

  # Lista das ferramentas necessárias
  local dependencies=("libncurses5-dev" "autoconf" "automake" "make" "git" "curl" "libssl-dev")
  local missing_dependencies=()

  # Verifica se cada dependência está instalada
  for dep in "${dependencies[@]}"; do
    if ! command_exists "$dep"; then
      missing_dependencies+=("$dep")
    fi
  done

  # Se alguma dependência estiver faltando, instala todas
  if [ ${#missing_dependencies[@]} -eq 0 ]; then
    echo "Todas as dependências já estão instaladas."
  else
    echo "Instalando as dependências faltantes: ${missing_dependencies[*]}"
    sudo apt update
    sudo apt install -y "${missing_dependencies[@]}"
    if [ $? -ne 0 ]; then
      echo "Erro ao instalar as dependências. Abortando."
      exit 1
    fi
  fi
}

# Cria o diretório 'asdf' na pasta home e clona o projeto do GitHub
clone_asdf_project() {
  echo "Clonando o projeto Asdf do GitHub..."
  local asdf_dir="$HOME/.asdf"

  # Se o diretório já existir, informe e saia da função
  if [ -d "$asdf_dir" ]; then
    echo "O diretório '.asdf' já existe. Nenhuma ação adicional necessária."
    return
  fi

  # Cria o diretório se não existir
  echo "Criando o diretório '.asdf' na sua pasta home..."
  mkdir "$asdf_dir"
  if [ $? -ne 0 ]; then
    echo "Erro ao criar o diretório '.asdf'. Abortando."
    exit 1
  fi

  # Clona o projeto do GitHub
  git clone --branch v0.14.0 https://github.com/asdf-vm/asdf.git "$asdf_dir"
  if [ $? -ne 0 ]; then
    echo "Erro ao clonar o projeto Asdf. Abortando."
    exit 1
  fi
}

# Instala os plugins do Erlang e Elixir usando o Asdf
install_asdf_plugins() {
  echo "Instalando plugins do Erlang e Elixir usando o Asdf..."

  # Verificar se o arquivo asdf.sh existe no diretório do Asdf
  asdf_sh="$HOME/.asdf/asdf.sh"
  if [ ! -f "$asdf_sh" ]; then
      echo "Arquivo asdf.sh não encontrado em $asdf_sh."
      exit 1
  fi

  # Carregar o arquivo asdf.sh
  . "$asdf_sh"

  # Instalar o plugin do Erlang
  echo "Instalando o plugin do Erlang..."
  asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git

  if [ $? -ne 0 ]; then
      echo "Erro ao instalar o plugin do Erlang. Abortando."
      exit 1
  fi

  # Instalar o plugin do Elixir
  echo "Instalando o plugin do Elixir..."
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

  if [ $? -ne 0 ]; then
      echo "Erro ao instalar o plugin do Elixir. Abortando."
      exit 1
  fi

  # Listar todas as versões disponíveis do Erlang
  echo "Listando todas as versões disponíveis do Erlang..."
  asdf list-all erlang

  # Instalar a última versão do Erlang da lista
  echo "Instalando a última versão do Erlang..."
  latest_erlang=$(asdf list-all erlang | grep -v '\[ \]' | tail -n 1)
  asdf install erlang "$latest_erlang"

  if [ $? -ne 0 ]; then
      echo "Erro ao instalar a última versão do Erlang. Abortando."
      exit 1
  fi

  # Listar todas as versões disponíveis do Elixir
  echo "Listando todas as versões disponíveis do Elixir..."
  asdf list-all elixir

  # Instalar a última versão do Elixir da lista
  echo "Instalando a última versão do Elixir..."
  latest_elixir=$(asdf list-all elixir | grep -v '\[ \]' | tail -n 1)
  asdf install elixir "$latest_elixir"

  if [ $? -ne 0 ]; then
      echo "Erro ao instalar a última versão do Elixir. Abortando."
      exit 1
  fi

  # Definir a versão instalada do Erlang como global
  echo "Definindo a última versão do Erlang como global..."
  asdf global erlang "$latest_erlang"

  if [ $? -ne 0 ]; then
      echo "Erro ao definir a última versão do Erlang como global. Abortando."
      exit 1
  fi

  # Definir a versão instalada do Elixir como global
  echo "Definindo a última versão do Elixir como global..."
  asdf global elixir "$latest_elixir"

  if [ $? -ne 0 ]; then
      echo "Erro ao definir a última versão do Elixir como global. Abortando."
      exit 1
  fi

  echo "Plugins do Erlang e Elixir instalados com sucesso."
}

# Executa todas as funções em ordem
check_dependencies
clone_asdf_project
install_asdf_plugins

echo "Verificação e instalação concluídas."
