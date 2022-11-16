# IBM Watson Speech to Text Library for Embed

The Watson Speech to Text Library (STT) for Embed transcribes written text from spoken audio. The service leverages machine learning to combine knowledge of grammar, language structure, and the composition of audio and voice signals to accurately transcribe the human voice.

## Introduction

This chart provides a functioning exemplar install of the IBM Watson Speech to Text Embed runtime on Kubernetes.

This chart should be treated as beta when considering compatibility and future changes. It is recommended to either copy and modify the chart or the manifests it renders.

Find out more about IBM Speech to Text Library for Embed by reading the [product documentation](https://www.ibm.com/docs/watson-libraries?topic=watson-speech-text-library-embed-home).

## Chart Details

This chart installs the following:

- STT runtime Deployment
  - HAProxy container used for TLS termination
  - The set of enabled models are downloaded and configured via `initContainers`
- Service to expose the Deployment
- ConfigMap with configuration files that are mounted into the containers
- TLS secrets with a self-signed CA and the server certificate

## Prerequisites

- [Helm 3](https://helm.sh/docs/intro/install/)
- [Get access to the images with an IBM entitlement key](https://www.ibm.com/docs/watson-libraries?topic=i-accessing-files)

### License acceptance

To run the Speech to Text images (runtime and models) the product licenses must be reviewed and accepted by setting the value `license: true`.

The product licenses are contained in the `/license` directory or can be [viewed online](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-DAJI-CHRHDK).

### Red Hat OpenShift SecurityContextConstraints

Security context constraints (SCCs) can be set on individual containers to control permissions. These permissions include actions a container can perform and what resources it can access. RedHat Openshift has a set of default SCCs to define a set of conditions that a container must run with to be accepted into the system.

These values are preset within the chart:

```yaml
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  privileged: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
```

## Installing the Chart

The containers deployed in this chart come from the IBM entitled registry. You must create a Secret with credentials to pull from the IBM entitled registry. `ibm-entitlement-key` is the default name, but this can be changed by updating the `imagePullSecrets` value.

An example command to create the pull secret:

```sh
  $ kubectl create secret docker-registry ibm-entitlement-key \
  --docker-server=cp.icr.io \
  --docker-username=<your-name> \
  --docker-password=<your-password> \
  --docker-email=<your-email>
```

Before installing the chart, the license terms must be reviewed. Set `license=true` when installing to accept the license:

```sh
$ helm install --set license=true --set nameOverride=stt my-release ./ibm-watson-stt-embed-runtime
```

By default, the models that are enabled are `en-US_Multimedia` and `en-US_Telephony` with `defaultModel` set to `en-US_Multimedia`.

To configure the install further, such as enabling additional models, it is recommended to use a [values configuration file](#configuration).

## Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running:

```sh
$ helm status my-release
```

## Uninstalling the Chart

To uninstall and delete the installed resources:

```sh
$ helm delete my-release
```

## Configuration

Helm charts have configurable values that can be set at install time. Refer to the base [values.yaml](values.yaml) for documentation and defaults for the values. Values can be changed using `--set` or using YAML files specified with `-f/--values`

An example YAML values file can be found below:

```yaml
# Required to indicate acceptance of the container product license
license: true

# Use a simpler name for resources created by the Helm chart
nameOverride: "stt"

# Change the default model when none is specified in the request
defaultModel: de-DE_Multimedia
# Enable additional models from the default ones (ensure that the default model is enabled)
models:
  arMSTelephony:
    enabled: true
  deDEMultimedia:
    enabled: true
  deDETelephony:
    enabled: true
```

See the [product's configuration documentation](https://www.ibm.com/docs/watson-libraries?topic=r-configuration-options) for details on how the containers are configured.
