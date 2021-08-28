# Usage: docker run --restart=always -v /var/data/blockchain-xmr:/root/.bitmonero -p 18080:18080 -p 18081:18081 --name=monerod -td kannix/monero-full-node
FROM ubuntu:20.04 AS build

ENV MONERO_VERSION=0.17.2.0 MONERO_SHA256=59e16c53b2aff8d9ab7a8ba3279ee826ac1f2480fbb98e79a149e6be23dd9086

RUN apt-get update && apt-get install -y curl bzip2

WORKDIR /root

RUN curl https://dlsrc.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2 -O &&\
  echo "$MONERO_SHA256  monero-linux-x64-v$MONERO_VERSION.tar.bz2" | sha256sum -c - &&\
  tar -xvf monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  rm monero-linux-x64-v$MONERO_VERSION.tar.bz2 &&\
  cp ./monero-x86_64-linux-gnu-v$MONERO_VERSION/monerod . &&\
  rm -r monero-*

FROM ubuntu:20.04

RUN useradd -ms /bin/bash monero && \
    mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero && \
# Added curl for connection verification
    apt-get update && apt-get install -y curl

USER monero
WORKDIR /home/monero

COPY --chown=monero:monero --from=build /root/monerod /home/monero/monerod

# blockchain location
VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081


ENTRYPOINT ["./monerod"]

#Added (local) tor-proxy for transactions
CMD ["--non-interactive", "--restricted-rpc", "--rpc-bind-ip=0.0.0.0", "--confirm-external-bind", "--enable-dns-blocklist", "--out-peers=16", "--tx-proxy=tor,10.0.3.45:9050,100,disable_noise"]
