#!/bin/bash

#
# Script de inicialização do container com nginx e ferramentas auxiliares
#

set -e

echo "[Entrypoint] Docker NGINX Stack"


# Criação da pasta utilizada pelos certificados criados (ou linkados)
mkdir -p /etc/letsencrypt/live/nginx

# Criação do root do certbot, para geração dos certificados
mkdir -p /var/www/certbot

# Criação do dhparam
openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 1024

# Criação de um certificado autoassinado, para ser utilizado caso não seja gerado um pelo certbot
openssl req -x509 -nodes -newkey rsa:1024 -days 365 \
		-keyout '/etc/letsencrypt/live/nginx/privkey.pem' -out '/etc/letsencrypt/live/nginx/fullchain.pem' -subj '/CN=localhost'

# Verifica se o parametros do Certbot foram informados, para geração do certificado válido
if [ "$CERTBOT_DOMAIN" -a "$CERTBOT_EMAIL" ]
then
	# Inicia o nginx para fazer a verificação do certbot (via webroot criado anteriormente)
	nginx -g 'daemon on;'

	# Obtem os certificados informados no docker-compose.yml
	certbot certonly --webroot -w /var/www/certbot -m "$CERTBOT_EMAIL" -d "$CERTBOT_DOMAIN" --agree-tos -n --post-hook "nginx -s reload"

	# Link os certificados gerados no local dos autoassinados
	ln -sf /etc/letsencrypt/live/"$CERTBOT_DOMAIN"/fullchain.pem /etc/letsencrypt/live/nginx/fullchain.pem
	ln -sf /etc/letsencrypt/live/"$CERTBOT_DOMAIN"/privkey.pem /etc/letsencrypt/live/nginx/privkey.pem

	# Para o processo do nginx (vai ser iniciado em foreground no final do processo)
	nginx -s stop
else
	echo "Parametros do Certbot não informados, continuando com os certificados autoassinados..."
fi


# Cria arquivos de configuração para o envio de email da sumarização do log
if [ "$SSMTP_EMAIL" -a "$SSMTP_HOST" -a "$SSMTP_PASSWORD" -a "$SSMTP_TOEMAIL" ] && [ "$SSMTP_TLS" -o "$SSMTP_STARTTLS" ] 
then
	echo "root=$SSMTP_EMAIL" > /etc/ssmtp/ssmtp.conf
	echo "mailhub=$SSMTP_HOST" >> /etc/ssmtp/ssmtp.conf
	echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
	echo "AuthUser=$SSMTP_EMAIL" >> /etc/ssmtp/ssmtp.conf
	echo "AuthPass=$SSMTP_PASSWORD" >> /etc/ssmtp/ssmtp.conf
	[[ "$SSMTP_TLS" == "YES" ]] && echo "UseTLS=YES" >> /etc/ssmtp/ssmtp.conf
	[[ "$SSMTP_STARTTLS" == "YES" ]] && echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf

	echo "root:$SSMTP_EMAIL:$SSMTP_HOST" > /etc/ssmtp/revaliases
	
	# Cria um arquivo com o email de destino
	echo "$SSMTP_TOEMAIL" > /etc/ssmtp/email_destino.txt

else
	echo "Informações de email incompletas, não configurando o ssmtp..."
fi

# Iniciar servico do cron para o logrotate
service cron start

# Iniciar o processo do nginx em foreground
nginx -g 'daemon off;'

