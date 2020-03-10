#!/bin/bash

##
# script para sumarizar o arquivo de log do nginx e enviar por email
##

# Verifica os parametros de email
if [ "$SSMTP_EMAIL" -a "$SSMTP_HOST" -a "$SSMTP_PASSWORD" -a "$SSMTP_TOEMAIL" ] && [ "$SSMTP_TLS" -o "$SSMTP_STARTTLS" ]
then
	# monta o header do email
	echo "To: $SSMTP_TOEMAIL" > /tmp/email
	echo "From: $SSMTP_EMAIL" >> /tmp/email
	echo "Subject: Sumarização das conexões - nginx/node-app - Ultimas 24 horas" >> /tmp/email
	echo "" >> /tmp/email

	# faz a sumarização
	cat /var/log/nginx/node-app.log.1 |sort|uniq -c >> /tmp/email

	# envia o email
	ssmtp $SSMTP_TOEMAIL < /tmp/email
else
	echo "Email não configurado!"
fi
