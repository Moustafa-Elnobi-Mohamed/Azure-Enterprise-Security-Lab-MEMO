FROM nginxinc/nginx-unprivileged:1.28.1-alpine

LABEL org.opencontainers.image.title="MEMO Secure App"
LABEL org.opencontainers.image.description="Hardened non-root container for the MEMO Azure Enterprise Security Lab"
LABEL org.opencontainers.image.vendor="MEMO Foundation"
LABEL org.opencontainers.image.version="1.0.0"

COPY --chown=101:101 default.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 index.html /usr/share/nginx/html/index.html

USER 101:101

EXPOSE 8080

HEALTHCHECK --interval=30s \
  --timeout=3s \
  --start-period=5s \
  --retries=3 \
  CMD ["wget", "--quiet", "--output-document=/dev/null", "http://127.0.0.1:8080/healthz"]

STOPSIGNAL SIGQUIT
