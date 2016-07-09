FROM alpine:3.4
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
