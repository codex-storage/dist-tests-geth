FROM ethereum/client-go:v1.11.6
RUN  apk --update add curl

COPY content .

ENTRYPOINT ["/usr/bin/env"]
CMD ["sh", "docker-entrypoint.sh"]
