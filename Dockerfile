FROM debian:bullseye-backports

# Install dependencies and add user
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    sudo \
    bash \
    supervisor && \
  update-ca-certificates && \
  rm -rf /var/lib/apt/lists/* && \
  groupadd -g 999 opuser && \
	useradd -r -u 999 -g opuser opuser && \
	mkdir -p /home/opuser/.op/data && \
	chown -R opuser /home/opuser && \
	chmod -R 700 /home/opuser/.op

# Copy the 1Password Connect binaries
COPY --from=1password/connect-api:latest /bin/connect-api /bin/
COPY --from=1password/connect-sync:latest /bin/connect-sync /bin/

# Copy configuration files and scripts
COPY src/etc/supervisord.conf /etc/supervisor/conf.d/supervisor.conf
COPY src/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod -R 0755 /docker-entrypoint.sh /etc/supervisor/conf.d/ && \
    chmod +x /docker-entrypoint.sh

EXPOSE 8080
VOLUME /home/opuser/.op/data
USER opuser

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/conf.d/supervisor.conf"]
