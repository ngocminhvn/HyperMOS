# Built while online, then the untrusted installer is run ONLY offline.
# No project secrets, repository mounts, host devices or network connections.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
       python3-minimal strace ltrace libssl3t64 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY bin/dump/sandbox_probe.py /opt/hypermos/sandbox_probe.py
RUN chmod 0444 /opt/hypermos/sandbox_probe.py
USER 65534:65534
WORKDIR /analysis
