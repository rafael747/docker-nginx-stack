#!/bin/bash


##
# script para sumarizar o arquivo de log do nginx e enviar por email
##

if [ "$SSMTP_EMAIL" -a "$SSMTP_HOST" -a "$SSMTP_PASSWORD" -a "$SSMTP_TOEMAIL" ]
then
	#monta o header do email
	echo "To: $SSMTP_TOEMAIL" > /tmp/email
	echo "From: $SSMTP_EMAIL" >> /tmp/email
	echo "Subject: Sumarização das conexões - nginx/node-app - `date +%F -d '-1 day'`" >> /tmp/email
	echo "" >> /tmp/email

	# faz a sumarização
	cat /var/log/nginx/node-app.log.1 |sort|uniq -c >> /tmp/email

	# envia o email
	#ssmtp $SSMTP_TOEMAIL < /tmp/email
fi
