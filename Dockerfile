FROM ubuntu:14.04

#! mapnik2.2 don't like libgeos version from postgis2.1
#! libgeos-c1 (= 3.2.2-3ubuntu1) but 3.3.3-1.1~pgdg12.4+1 is to be installed
#! FROM helmi03/postgis:2.1

MAINTAINER Helmi <helmi03@gmail.com>

RUN apt-get update
RUN apt-get install -y -q python-software-properties python-pip libzmq-dev

# pillow prerequisites
RUN apt-get install -y -q libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk
RUN apt-get install -y -q python-dev python-imaging
RUN ln -s /usr/include/freetype2 /usr/local/include/freetype

RUN pip install -U pillow modestmaps simplejson werkzeug

# install mapnik
RUN apt-get install -y -q software-properties-common
# RUN add-apt-repository ppa:mapnik/boost
RUN apt-get update
RUN apt-get install -y -q \
libpq-dev \
libboost-dev \
libboost-filesystem-dev \
libboost-program-options-dev \
libboost-python-dev \
libboost-regex-dev \
libboost-system-dev \
libboost-thread-dev \
libicu-dev \
python-dev libxml2 libxml2-dev \
libfreetype6 libfreetype6-dev \
libjpeg-dev \
libpng-dev \
libproj-dev \
libtiff-dev \
libcairo2 libcairo2-dev python-cairo python-cairo-dev \
libcairomm-1.0-1 libcairomm-1.0-dev \
ttf-unifont ttf-dejavu ttf-dejavu-core ttf-dejavu-extra \
git build-essential python-nose \
libgdal1-dev python-gdal \
postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 \
libsqlite3-dev

RUN apt-get install wget
# install harfbuzz
RUN wget http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.26.tar.bz2 && \
    tar xf harfbuzz-0.9.26.tar.bz2 && \
    cd harfbuzz-0.9.26 && \
    ./configure && \
    make && make install && \
    ldconfig

RUN git clone https://github.com/mapnik/mapnik.git && cd mapnik && git checkout v3.0.8 && git submodule update --init && ./configure && make && make make install

# mapnik python bindings
RUN git clone git@github.com:mapnik/python-mapnik.git && cd python-mapnik && python setup.py install

RUN pip install -q https://github.com/helmi03/TileStache/tarball/master

RUN pip install circus chaussette gevent
# when use PIL="decoder zip not available"
# Can use this workaround, but testing Pillow for now
# http://obroll.com/install-python-pil-python-image-library-on-ubuntu-11-10-oneiric/

RUN yes | apt-get install -y ttf-mscorefonts-installer
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD circus.ini /etc/circus.ini
ADD tilestache.cfg /etc/tilestache/tilestache.cfg
ADD app.py /app.py
ADD start_tilestache.sh /usr/local/bin/start_tilestache

EXPOSE 9999

#!-- Docker have problem with upstart
#! ADD circus.cont /etc/init/circus.conf
#! CMD ["start", "circus"]

CMD ["start_tilestache"]
