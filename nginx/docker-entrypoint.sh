#!/bin/bash

#TODO:
# - Verificar variavel de ambiente e gerar (tentar) certificados ssl (dentro de volume) ou gerar um certificado localmente

set -e


mkdir -p /etc/letsencrypt/live/nginx
mkdir -p /var/www/certbot




# Criação do dhparam
openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 1024

# cria um certificado autoassinado
openssl req -x509 -nodes -newkey rsa:1024 -days 365 \
		-keyout '/etc/letsencrypt/live/nginx/privkey.pem' -out '/etc/letsencrypt/live/nginx/fullchain.pem' -subj '/CN=localhost'

# Verifica se o parametros do certbot foram informados
if [ "$CERTBOT_DOMAIN" -a "$CERTBOT_MAIL" ]
then
	#inicia o nginx para fazer a verificação do certbot

	nginx -g 'daemon on;'

	certbot certonly --webroot -w /var/www/certbot -m "$CERTBOT_MAIL" -d "$CERTBOT_DOMAIN" --agree-tos -n --post-hook "nginx -s reload"
	ln -sf /etc/letsencrypt/live/"$CERTBOT_DOMAIN"/fullchain.pem /etc/letsencrypt/live/nginx/fullchain.pem
	ln -sf /etc/letsencrypt/live/"$CERTBOT_DOMAIN"/privkey.pem /etc/letsencrypt/live/nginx/privkey.pem

	nginx -s stop

fi




#se o certificado não existir
#if [ ! -f /etc/letsencrypt/live/nginx/privkey.pem ]
#then
#	openssl req -x509 -nodes -newkey rsa:1024 -days 365 -keyout '/etc/letsencrypt/live/nginx/privkey.pem' -out '/etc/letsencrypt/live/nginx/fullchain.pem' -subj '/CN=localhost'
#fi



# certbot certonly --webroot -w /var/www/certbot -m rafel747@gmail.com -d rafael-ltly.localhost.run --agree-tos -n

#ln -s /etc/letsencrypt/live/rafael-ltly.localhost.run/fullchain.pem /etc/letsencrypt/live/nginx/fullchain.pem -f
#ln -s /etc/letsencrypt/live/rafael-ltly.localhost.run/privkey.pem /etc/letsencrypt/live/nginx/privkey.pem -f

# Iniciar servico do cron para o logrotate
service cron start

nginx -g 'daemon off;'


sleep 10000000

#certbot certonly --webroot -w /var/www/certbot \
#    $staging_arg \
#    $email_arg \
#    $domain_args \
#    --rsa-key-size $rsa_key_size \
#    --agree-tos


#openssl req -x509 -nodes -newkey rsa:1024 -days 365
#    -keyout '$path/privkey.pem' \
#    -out '$path/fullchain.pem' \
#    -subj '/CN=localhost'"






# link: ln -sf /etc/letsencrypt/live/$domain/cert /etc/letsencrypt/live/nginx/cert


# - Criar um link para o certificado gerado para um nome fixo
# - verificar e gerar arquivo de dhparams
# - 
# - inicia script (loop) para renovar os certificados 
# - inicia o processo do cron (entrypoint atual)
# - inicia o processo do nginx
# - 
