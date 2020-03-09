# docker-nginx-stack
Stack de serviços web com nginx como proxy reverso para microserviços

# Instalação do Ambiente

O ambiente proposto utiliza docker + swarm para criação dos serviços.
Sendo assim a única dependencia que precisa ser instalada é o docker:

> Exemplo de instalação do docker com um script automatizado (disponibilizado pelo proprio docker):

  curl https://get.docker.com|sudo bash

> após a instalação, é necessário incluir o usuário do sistema no grupo "docker". Após isso, relogar no sistema (ou usar o comando: newgrp docker)

Para a utilização no modo swarm, é necessário executar o seguinte comando:

  docker swarm init

Nesse passo é possível incluir outros nós nesse swarm, seguindo as instruções na tela


# Criação da imagem com a aplicação node

  cd node-app
  docker build . -t rafaelcarreira/node-app:1.0

# Configuração do nginx (com certbot, cron, logrotate, etc..)

  cd nginx 
  docker build . -t rafaelcarreira/nginx-stack:1.0

# Iniciando os serviços com swarm

  docker stack deploy -c docker-compose.yml stack


# TODO:
 - Configuração do proxy reverso (nginx) com http e https
 - Criar instancias para cada numero de cpus
 - Monitorar os processos e reiniciar/subir os serviços se necessário
 - Script para teste de carga, medindo o Throughput 
 - Service para parsear o log de acesso, enviar email sumarizado
 - Fazer o parse dos logs no momento do teste de carga


