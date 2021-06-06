FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SATISFY_RELEASE
LABEL build_version="shangmob version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="skyer"

ENV APP_ROOT=/var/www/satisfy

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache --upgrade \
	curl \
	php7-curl \
	php7-phar \
	php7-tokenizer \
	php7-dom \
	php7-zip \
	tar && \
 echo "**** install  composer ****" && \
 cd /tmp && \
 curl -sS https://getcomposer.org/installer | php && \
 mv /tmp/composer.phar /usr/local/bin/composer && \
 echo "**** fetch satisfy ****" && \
 mkdir -p \
	${APP_ROOT} && \
 if [ -z ${SATISFY_RELEASE+x} ]; then \
	SATISFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/ludofleury/satisfy/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/satisfy.tar.gz -L \
	"https://github.com/ludofleury/satisfy/archive/${SATISFY_RELEASE}.tar.gz" && \
 tar xf \
	/tmp/satisfy.tar.gz -C \
	${APP_ROOT}/ --strip-components=1 && \
 echo "**** install composer dependencies ****" && \
 composer install -d ${APP_ROOT} && \
 echo "**** cleanup ****" && \
 rm -rf \
	/root/.composer \
	/tmp/*

# give abc a home folder, needed for comictagger prefs.
RUN usermod -d /config abc

# add local files
COPY root/ /
