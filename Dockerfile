FROM alpine:latest

# Set up insecure default key
RUN mkdir -m 0750 /Users/jijiaban/.android
ADD files/adbkey /Users/jijiaban/.android/adbkey
ADD files/adbkey.pub /Users/jijiaban/.android/adbkey.pub
ADD files/update-platform-tools.sh /usr/local/bin/update-platform-tools.sh

RUN set -xeo pipefail && \
    apk update && \
    apk add --no-cache ca-certificates wget tini && \
    wget -q -O "/etc/apk/keys/sgerrand.rsa.pub" \
      "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub" && \
    wget -O "/tmp/glibc.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-2.33-r0.apk" && \
    wget -O "/tmp/glibc-bin.apk" \
      "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.33-r0/glibc-bin-2.33-r0.apk" && \
    apk add --no-cache --allow-untrusted "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    rm "/root/.wget-hsts" && \
    rm "/tmp/glibc.apk" "/tmp/glibc-bin.apk" && \
    rm -r /var/cache/apk/APKINDEX.* && \
    /usr/local/bin/update-platform-tools.sh

# Expose default ADB port
EXPOSE 5037

# Set up PATH
ENV PATH $PATH:/opt/platform-tools

# Hook up tini as the default init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start the server by default
CMD ["adb", "-a", "-P", "5037", "server", "nodaemon"]
