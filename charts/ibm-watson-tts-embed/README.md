# IBM Watson Text to Speech Library for Embed

The Watson Text to Speech (TTS) Library for Embed synthesizes natural-sounding speech from written text. The service streams the results back to the client with minimal delay.

## Introduction

This chart provides a functioning exemplar install of the IBM Watson Text to Speech Embed with runtime and customization on Kubernetes.

This chart should be treated as beta when considering compatibility and future changes. It is recommended to either copy and modify the chart or the manifests it renders.

Find out more about IBM Text to Speech Library for Embed by reading the [product documentation](https://www.ibm.com/docs/watson-libraries?topic=watson-text-speech-library-embed-home).

## Chart Details

This chart installs the following:

- TTS customization Deployment
  - `initContainer` that will create the required PostgreSQL database
- TTS runtime Deployment
  - HAProxy container used for TLS termination
- Job(s) to upload the set of enabled TTS models into storage
- Services to expose the Deployments
- Secrets for PostgreSQL and model storage
- TLS secrets with a self-signed CA and the server certificate

## Prerequisites

- [Helm 3](https://helm.sh/docs/intro/install/)
- [Get access to the images with an IBM entitlement key](https://www.ibm.com/docs/watson-libraries?topic=i-accessing-files-1)
- Customization requires:
  - S3 Compatible Storage must exist that supports HMAC (access key and secret key) credentials. Speech to Text requires one bucket that it can read and write objects to. The bucket will be populated with stock models at install time and will also store customization artifacts, including training data and trained models.
  - PostgreSQL Database is required to manage metadata related to customization.
- Kubernetes Cluster - the Speech to Text service is assumed to be running in a Kubernetes cluster.

### License acceptance

To run the Text to Speech images (runtime and models) the product licenses must be reviewed and accepted by setting the value `license: true`.

The product licenses are contained in the `/license` directory or can be [viewed online](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?li_formnum=L-DAJI-CJULPU).

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
$ helm install --set license=true --set nameOverride=tts my-release ./ibm-watson-tts-embed
```

By default, the models that are enabled are `en-US_MichaelV3Voice` and `en-US_AllisonV3Voice` with `defaultModel` set to `en-US_AllisonV3Voice`.

To configure the install further, such as enabling additional models, it is recommended to use a [values configuration file](#configuration).

## Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command.

```sh
$ helm status my-release
```

For basic usage of customization, see the customizing Watson Speech Library for Embed [documentation](https://www.ibm.com/docs/en/watson-libraries?topic=containers-customization-example).

The complete API reference for Watson Text-to-Speech can be found [here](https://cloud.ibm.com/apidocs/text-to-speech). Note that custom pronunciation is supported but not voice transformation.

## Uninstalling the Chart

To uninstall and delete the Text to Speech deployment, run the following command:

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
nameOverride: "tts"

# Change the default model when none is specified in the request
defaultModel: de-DE_BrigitV3Voice
# Enable additional models from the default ones
models:
  deDEBirgitV3Voice:
    enabled: true
  esESLauraV3Voice:
    enabled: true

# objectStorage has configuration for an s3 compatible object storage for models storage
objectStorage:
  endpoint: http://minio:9000
  region: local
  accessKey: myAccessKey
  secretKey: mySecretKey

# postgres has configuration for a PostgreSQL instance that will store data and
# metadata for customizations
postgres:
  host: postgres.myNamespace.svc
  port: "5432"
  user: postgres
  password: myPassword
```

See the [product's configuration documentation](https://www.ibm.com/docs/watson-libraries?topic=r-configuration-options-1) for details on how the containers are configured.
