# Image Mode - Base OS

Hardened RHEL bootc base image used by all Train Tickets application tiers.

## What it includes

- RHEL 10 bootc base
- PCI-DSS compliance profile applied via OpenSCAP
- System utilities (tmux, insights-client)
- A default `bootc-user` account (password: `redhat`)
- Red Hat Insights auto-registration via `rhc-connect.service`

## Configuration

To enable Red Hat Insights registration, populate `.rhc_connect_credentials` with:

```
RHC_ACT_KEY=<your-activation-key>
RHC_ORG_ID=<your-org-id>
```

See https://console.redhat.com/insights/connector/activation-keys

## Build

```bash
podman build -t quay.io/kubealex/image-mode-baseos:latest .
```

## Tags

| Tag | RHEL Version |
|-----|-------------|
| `latest` | RHEL 10.2 (current) |
| `rhel10.2` | RHEL 10.2 |
| `rhel10.1` | RHEL 10.1 |
