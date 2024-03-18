FROM softwaresecurityproject/zap-stable 

ENV HTTP_PROXY=http://localhost:8118 HTTPS_PROXY=http://localhost:8118
USER root

RUN apt-get update && apt-get install -q -y --fix-missing \
	privoxy \
	tor \
	curl && \
	rm -rf /var/lib/apt/lists/*


USER 1000

COPY config .
COPY scan.sh . 
COPY entrypoint.sh .
COPY swagger.json .
COPY torrc /etc/tor/
COPY --chown=1000:1 config /tmp/privoxy/config

ENTRYPOINT ["/zap/entrypoint.sh"]
