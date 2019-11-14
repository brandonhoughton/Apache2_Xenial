FROM ubuntu:xenial
LABEL maintainer="brandonhoughton"

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV TERM xterm

ENV APACHE_CONF_DIR=/etc/apache2

ENV OS_LOCALE="en_US.UTF-8"
RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    DEBIAN_FRONTEND=noninteractive

# Configure user nobody to match unRAID's settings
 RUN \
 usermod -u 99 nobody && \
 usermod -g 100 nobody && \
 usermod -d /home nobody && \
 chown -R nobody:users /home

RUN apt-get update 
RUN apt-get install -qy mc
RUN apt-get install -qy nano
RUN apt-get install -qy tmux

# Install webserver
RUN \
  apt-get update -q && \
  apt-get install -qy apache2 curl libcurl3 lynx && \
  apt-get clean -y && \
  rm -rf /var/lib/apt/lists/*

# Link web configuration folder
RUN \
  service apache2 restart && \
  rm -R -f /var/www && \
  ln -s /web /var/www

# Update apache configuration with this one
RUN \
  mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
  rm /etc/apache2/sites-available/* && \
  rm /etc/apache2/apache2.conf && \
  ln -s /config/config.conf /etc/apache2/sites-available/000-default.conf && \
  ln -s /var/log/apache2 /logs

COPY ./config/default.conf /etc/apache2/000-default.conf
COPY ./config/apache2.conf /etc/apache2/apache2.conf
COPY ./config/ports.conf /etc/apache2/ports.conf

# # Manually set the apache environment variables in order to get apache to work immediately.
# RUN \
#   echo www-data > /etc/container_environment/APACHE_RUN_USER && \
#   echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
#   echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
#   echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
#   echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
#   echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR

# Expose Ports
EXPOSE 80 443

# The www directory and proxy config location
VOLUME ["/config", "/web", "/logs"]

# Add our crontab file
ADD ./config/crons.conf /root/crons.conf

# # Add firstrun.sh to execute during container startup
# ADD firstrun.sh /etc/my_init.d/firstrun.sh
# RUN chmod +x /etc/my_init.d/firstrun.sh

# # Add inotify.sh to execute during container startup
# RUN mkdir /etc/service/inotify
# ADD inotify.sh /etc/service/inotify/run
# RUN chmod +x /etc/service/inotify/run

# # Add apache to runit
# RUN mkdir /etc/service/apache
# ADD apache-run.sh /etc/service/apache/run
# RUN chmod +x /etc/service/apache/run
# ADD apache-finish.sh /etc/service/apache/finish
# RUN chmod +x /etc/service/apache/finish


# By default, simply start apache.
COPY entrypoint.sh /sbin/entrypoint.sh
CMD ["/sbin/entrypoint.sh"]












# ENV APACHE_CONF_DIR=/etc/apache2

# RUN \
#   service apache2 restart && \
#   rm -R -f /var/www && \
#   ln -s /web /var/www
  


# COPY ./app /var/www/app/
# COPY entrypoint.sh /sbin/entrypoint.sh

# # Install proxy Dependencies
# RUN \
#   apt-get update -q && \
#   apt-get install -qy apache2 curl && \
#   apt-get clean -y && \
#   rm -rf /var/lib/apt/lists/*


# RUN	\
# 	BUILD_DEPS='software-properties-common python-software-properties' \
#     && dpkg-reconfigure locales \
# 	&& apt-get install --no-install-recommends -y $BUILD_DEPS \
# 	&& add-apt-repository -y ppa:ondrej/php \
# 	&& add-apt-repository -y ppa:ondrej/apache2 \
# 	&& apt-get update \
#     && apt-get install -y curl apache2 nano htop lynx\
#     # Apache settings
#     && cp /dev/null ${APACHE_CONF_DIR}/conf-available/other-vhosts-access-log.conf \
#     && rm ${APACHE_CONF_DIR}/sites-enabled/000-default.conf ${APACHE_CONF_DIR}/sites-available/000-default.conf \
#     && a2enmod rewrite php5.6 \
# 	# Cleaning
# 	&& apt-get purge -y --auto-remove $BUILD_DEPS \
# 	&& apt-get autoremove -y \
# 	&& rm -rf /var/lib/apt/lists/* \
# 	# Forward request and error logs to docker log collector
# 	&& ln -sf /dev/stdout /var/log/apache2/access.log \
# 	&& ln -sf /dev/stderr /var/log/apache2/error.log \
# 	&& chmod 755 /sbin/entrypoint.sh \
#     && chown www-data:www-data ${PHP_DATA_DIR} -Rf

# COPY ./configs/apache2.conf ${APACHE_CONF_DIR}/apache2.conf
# COPY ./configs/default.conf ${APACHE_CONF_DIR}/sites-enabled/default.conf

# WORKDIR /var/www/app/

# EXPOSE 80 443



 
# RUN \
#   service apache2 restart && \
#   rm -R -f /var/www && \
#   ln -s /web /var/www
  
# # Update apache configuration with this one
# RUN \
#   mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
#   rm /etc/apache2/sites-available/* && \
#   rm /etc/apache2/apache2.conf && \
#   ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
#   ln -s /var/log/apache2 /logs

# ADD proxy-config.conf /etc/apache2/000-default.conf
# ADD apache2.conf /etc/apache2/apache2.conf
# ADD ports.conf /etc/apache2/ports.conf

# # Manually set the apache environment variables in order to get apache to work immediately.
# RUN \
# echo www-data > /etc/container_environment/APACHE_RUN_USER && \
# echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
# echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
# echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
# echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
# echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR

# # Expose Ports
# EXPOSE 80 443

# # The www directory and proxy config location
# VOLUME ["/config", "/web", "/logs"]


# # Add our crontab and Adminer files
# ADD crons.conf /root/crons.conf
# ADD index.php /root/index.php
# ADD .htpasswd /root/.htpasswd




# # Add firstrun.sh to execute during container startup
# ADD firstrun.sh /etc/my_init.d/firstrun.sh
# RUN chmod +x /etc/my_init.d/firstrun.sh

# # Add inotify.sh to execute during container startup
# RUN mkdir /etc/service/inotify
# ADD inotify.sh /etc/service/inotify/run
# RUN chmod +x /etc/service/inotify/run



# # Add apache to runit
# RUN mkdir /etc/service/apache
# ADD apache-run.sh /etc/service/apache/run
# RUN chmod +x /etc/service/apache/run
# ADD apache-finish.sh /etc/service/apache/finish
# RUN chmod +x /etc/service/apache/finish