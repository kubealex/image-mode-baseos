FROM registry.redhat.io/rhel10/rhel-bootc:10.2
RUN dnf install -y tmux mkpasswd insights-client openscap-utils scap-security-guide cloud-init && dnf clean all

RUN oscap-im --profile pci-dss /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml

RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo
COPY demo-key.pub /tmp/demo-key.pub
RUN mkdir -p /home/bootc-user/.ssh && \
    cp /tmp/demo-key.pub /home/bootc-user/.ssh/authorized_keys && \
    chown -R bootc-user:bootc-user /home/bootc-user/.ssh && \
    chmod 700 /home/bootc-user/.ssh && \
    chmod 600 /home/bootc-user/.ssh/authorized_keys && \
    rm /tmp/demo-key.pub
RUN echo "Welcome to this PCI-DSS compliant RHEL Server" > /etc/motd.d/00-hello.motd

# Registering machine to Red Hat Insights
# Populate the .rhc_connect_credentials file with RHC_ACT_KEY=activation key and RHC_ORG_ID=organization id.
# See https://console.redhat.com/insights/connector/activation-keys

COPY rhc-connect.service /usr/lib/systemd/system/rhc-connect.service
COPY .rhc_connect_credentials /etc/rhc/.rhc_connect_credentials
RUN systemctl enable rhc-connect && touch /etc/rhc/.run_rhc_connect_next_boot
RUN systemctl mask bootc-fetch-apply-updates.timer

RUN printf 'net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\n' \
    > /etc/sysctl.d/99-disable-ipv6.conf

# Install bootc-api status service
ARG TARGETARCH=amd64
RUN curl -fsSL -o /usr/local/bin/bootc-api \
    "https://github.com/kubealex/bootc-api/releases/latest/download/bootc-api-linux-${TARGETARCH}" && \
    chmod +x /usr/local/bin/bootc-api

COPY bootc-api.service /etc/systemd/system/bootc-api.service
RUN systemctl enable bootc-api.service
RUN firewall-offline-cmd --zone=public --add-port=8005/tcp