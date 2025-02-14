FROM golang:1.13

COPY cmd/freegeoip/public /var/www

ADD . /go/src/github.com/cryptlex/freegeoip
RUN \
	cd /go/src/github.com/cryptlex/freegeoip/cmd/freegeoip && \
	go mod download && go get -d && go install && \
	apt-get update && apt-get install -y libcap2-bin && \
	setcap cap_net_bind_service=+ep /go/bin/freegeoip && \
	apt-get clean && rm -rf /var/lib/apt/lists/* && \
	useradd -ms /bin/bash freegeoip

# Set the license key as an environment variable
ENV MAXMIND_LICENSE_KEY=""
ENV INITIAL_DATABASE_URL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&suffix=tar.gz&license_key=${MAXMIND_LICENSE_KEY}"

USER freegeoip

CMD export FREEGEOIP_HTTP=:$PORT && /go/bin/freegeoip

# CMD instructions:
# Add  "-use-x-forwarded-for"      if your server is behind a reverse proxy
# Add  "-public", "/var/www"       to enable the web front-end
# Add  "-internal-server", "8888"  to enable the pprof+metrics server
#
# Example:
# CMD ["-use-x-forwarded-for", "-public", "/var/www", "-internal-server", "8888"]
