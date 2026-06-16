FROM registry.redhat.io/rhel10/rhel-bootc:10.1
RUN dnf install -y tmux mkpasswd insights-client openscap-utils scap-security-guide && dnf clean all

RUN oscap-im --profile pci-dss /usr/share/xml/scap/ssg/content/ssg-rhel10-ds.xml

RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo
RUN echo "Welcome to this PCI-DSS compliant RHEL Server" > /etc/motd.d/00-hello.motd

# Registering machine to Red Hat Insights
# Populate the .rhc_connect_credentials file with RHC_ACT_KEY=activation key and RHC_ORG_ID=organization id.
# See https://console.redhat.com/insights/connector/activation-keys

COPY rhc-connect.service /usr/lib/systemd/system/rhc-connect.service
COPY .rhc_connect_credentials /etc/rhc/.rhc_connect_credentials
RUN systemctl enable rhc-connect && touch /etc/rhc/.run_rhc_connect_next_boot
RUN systemctl mask bootc-fetch-apply-updates.timer