FROM ethereum/client-go:v1.11.5

COPY content .

ENTRYPOINT ["/usr/bin/env"]
CMD ["sh", "docker-entrypoint.sh"]
