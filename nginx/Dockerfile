FROM ubuntu:18.04

# Instalação dos pacotes
RUN apt-get update && apt-get -y install nginx logrotate ssmtp certbot curl

# Opções de SSL recomendadas
COPY options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf

# Configuração do nginx como proxy
COPY nginx.conf /etc/nginx/nginx.conf

# Configuração do logrotate para os logs gerados pelo nginx
COPY logrotate.conf /etc/logrotate.conf

# Script de sumarização do log do nginx e envio de email
COPY nginx-log-email.sh /nginx-log-email.sh 

# Script de inicialização dos serviços
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

