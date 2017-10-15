FROM multiarch/debian-debootstrap:armhf-jessie

RUN apt-get update && apt-get install -y wget curl

# add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r kibana && useradd -r -m -g kibana kibana

RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        wget \
        libfontconfig \
        libfreetype6 \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

#RUN id nobody && gosu nobody true

# grab tini for signal processing and zombie killing
ENV TINI_VERSION v0.16.1
RUN set -x \
    && wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
    && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
    && rm -rf "$GNUPGHOME" /usr/local/bin/tini.asc \
    && chmod +x /usr/local/bin/tini \
    && tini -h

RUN apt-get update && apt-get install -y git
#RUN curl -sL https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz | tar xvzf - --strip-components 1 -C /opt/kibana

ENV KIBANA_VERSION=5.6.3

RUN git clone https://github.com/elastic/kibana /opt/kibana \
 && cd /opt/kibana \
 && git checkout tags/v${KIBANA_VERSION} \
 && git checkout -b local/v${KIBANA_VERSION}

#RUN set -x \
# && mkdir -p /opt/kibana \
# && curl -sL https://github.com/elastic/kibana/archive/v${KIBANA_VERSION}.tar.gz | tar xvzf - --strip-components=1 -C /opt/kibana

RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
 && apt-get update && apt-get install -y lsb-release \
 && export VERSION=node_6.x \
 && export DISTRO="$(lsb_release -s -c)" \
 && echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list \
 && echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && apt-get install -y nodejs 

#RUN rm -f /opt/kibana/node/bin/node /opt/kibana/node/bin/npm
#RUN ln -sf /usr/bin/nodejs /opt/kibana/node/bin/node \
# && ln -sf /usr/bin/npm /opt/kibana/node/bin/npm

# && chmod o+w /opt/kibana/optimize/.babelcache.json \
RUN chown -R kibana:kibana /opt/kibana \
 && sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://es:9200'!" /opt/kibana/config/kibana.yml \
 && grep -q 'es:9200' /opt/kibana/config/kibana.yml \
 && sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" /opt/kibana/config/kibana.yml \
 && grep -q "^server\.host: '0.0.0.0'\$" /opt/kibana/config/kibana.yml

ENV PATH /opt/kibana/bin:/opt/kibana/node_modules/.bin:$PATH

WORKDIR /opt/kibana

RUN apt-get update \
 && apt-get install -y build-essential make libkrb5-dev gcc pkg-config libcairo2-dev libpng-dev libjpeg-dev libgif-dev g++ gyp node-gyp

RUN rm -fr node_modules \
 && npm install

#RUN npm install --save-dev @elastic/babel-preset-kibana

RUN npm run build -- --skip-archives

ENV XPACK_VERSION=5.6.3 \
    XPACK_TARBALL="https://artifacts.elastic.co/downloads/packs/x-pack/x-pack-5.6.3.zip" \
    XPACK_TARBALL_SHA1="fa9b2b58bf7d373202f586036d4ddf760b6eeba0"

# Install X-PACK
RUN set -ex ; \
    wget -O x-pack.tar.gz "$XPACK_TARBALL"; \
    if [ "$XPACK_TARBALL_SHA1" ]; then \
      echo "$XPACK_TARBALL_SHA1 *x-pack.tar.gz" | sha1sum -c -; \
    fi; \
    kibana-plugin install --batch file://$PWD/x-pack.tar.gz ; \
    rm -f x-pack.tar.gz

COPY docker-entrypoint.sh /

EXPOSE 5601
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD npm start

