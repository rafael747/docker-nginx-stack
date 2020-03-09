FROM ubuntu

# Install logrotate
RUN apt-get update && apt-get -y install nginx logrotate ssmtp certbot vim procps

# Remove sym links from nginx image
#RUN rm /var/log/nginx/access.log
#RUN rm /var/log/nginx/error.log

#copy nginx ssl options
COPY options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf

# Copy MyApp nginx config
COPY nginx.conf /etc/nginx/nginx.conf

#Copy logrotate nginx configuration
COPY logrotate.conf /etc/logrotate.d/nginx

COPY ssmtp.conf /etc/ssmtp/ssmtp.conf


COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Start nginx and cron as a service
#CMD service cron start && nginx -g 'daemon off;'
