FROM 32bit/ubuntu:16.04
MAINTAINER jarnoh@komplex.org

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

ENV DEBIAN_FRONTEND=noninteractive

COPY ubuntu-wine.list /etc/apt/sources.list.d/ubuntu-wine.list

WORKDIR /work

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 883E8688397576B6C509DF495A9A06AEF9CB8DB0 && \
  apt-get update && \
  apt-get -y install --no-install-recommends wine1.8 winetricks libpulse0 inotify-tools curl exiv2 && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*.log /var/log/apt/*.log /var/cache/debconf 

ENV WINEPREFIX=/usr/local/dngconverter WINEARCH=win32 WINEDLLOVERRIDES=mscoree,mshtml= DISPLAY=:0.0

RUN winetricks settings win7

COPY dngconverter /usr/local/bin
COPY install /usr/local/bin

# download links http://supportdownloads.adobe.com/product.jsp?product=106&platform=Windows
ENV DNGVER=10_4
RUN wget http://download.adobe.com/pub/adobe/dng/win/DNGConverter_${DNGVER}.exe && /usr/local/bin/install DNGConverter_${DNGVER}.exe && rm -f DNGConverter_${DNGVER}.exe

# make wine silent
ENV WINEDEBUG -all

COPY monitor /usr/local/bin
ENTRYPOINT ["/usr/local/bin/monitor"]
