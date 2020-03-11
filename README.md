# docker-nginx-stack
Stack de serviços web com nginx como proxy reverso para microserviços

# Instalação do Ambiente

O ambiente proposto utiliza docker + swarm para criação dos serviços.
Sendo assim, a única dependência que precisa ser instalada é o docker:

  - Exemplo de instalação do docker com um script automatizado (disponibilizado pelo próprio docker):

```
curl https://get.docker.com|sudo bash
```

> após a instalação, é necessário incluir o usuário do sistema no grupo "docker". Após isso, relogar no sistema (ou usar o comando: newgrp docker)

  - Para a utilização no modo swarm, é necessário executar o seguinte comando:

```
docker swarm init
```

Nesse passo é possível incluir outros nós nesse swarm, seguindo as instruções na tela.
Cada nó incluído no cluster terá um container da aplicação node utilizando o gerenciador **pm2**.
O mesmo irá iniciar uma instância da aplicação em node para cada núcleo disponível na máquina

# Criação da imagem com a aplicação node

```
cd node-app
docker build . -t rafaelcarreira/node-app:1.0		#essa imagem já está disponível no registry dockerhub
```

# Criação da imagem com a stack nginx (com certbot, ssmtp, cron, logrotate, etc..)

```
cd nginx 
docker build . -t rafaelcarreira/nginx-stack:1.0	#essa imagem já está disponível no registry dockerhub
```

# Configurações necessárias no arquivo **docker-compose.yml**

  - Configurações para geração de certificado utilizando o certbot:

```
     - CERTBOT_DOMAIN=dominio.tld
     - CERTBOT_MAIL=email@dominio.tld
```

  - Configurações de email para envio da sumarização dos acessos (exemplo gmail):

```
      - SSMTP_EMAIL=meu-email@gmail.com
      - SSMTP_HOST=smtp.gmail.com:465
      - SSMTP_TLS=YES
      - SSMTP_TOEMAIL=destino@gmail.com
      - SSMTP_PASSWORD=minha-senha
```

# Iniciando os serviços com swarm

```
  docker stack deploy -c docker-compose.yml stack
```

# Funcionamento

Feito isso, o serviço fica disponível nos nós que estarão rodando a stack.
Todo o tráfego na porta 443 (ssl) e 80 (com redirect para a 443) será roteado até o serviço com nginx,
servindo de proxy para os nós rodando o serviço de node, onde é feito um loadbalance com o **pm2**
o serviço com nginx armazena os logs em um volume e envia uma sumarização das requisições uma vez ao dia.


# Volumes utilizados

  - NGINX_CERTS

>Utilizado para armazenar os certificados gerados via certbot ou os autoassinados

  - NGINX_LOGS
 
>Utilizado para persistir os arquivos de log do nginx.

# Foram configuradas healthchecks para os serviços

```
  curl -f https://localhost -k || false		#para o service com nginx
  curl -f http://localhost:3000 || false	#para o service com node
```

**Caso esses serviços parem de responder a essas requisições, a instância é substituída**

# Envio de emails com a sumarização das conexões

É utilizada a ferramenta **logrotate** para rotacionar o arquivo de log do nginx uma vez ao dia (daily)
Após esse processo, é executado o script **nginx-log-email.sh** para sumarizar e enviar os logs para o email definido no **docker-compose.yml**

# Fazendo um teste de carga da stack

  - Essa abordagem utiliza a ferramenta "ab" do pacote **apache2-utils**

```
  ab -c 10 -n 100000 https://localhost/
```

Esse comando faz 100.000 requisições utilizando 10 processos concorrentes.
Após a finalização, serão exibidas as estatísticas do teste

# Forçar o rotacionamento do log e o envio do email

  - Após o teste de carga, é possível forçar o rotacionamento do log, a sumarização e o envio do email
```
  docker container exec -ti <container-rodando-nginx> /usr/sbin/logrotate /etc/logrotate.conf --force
```
