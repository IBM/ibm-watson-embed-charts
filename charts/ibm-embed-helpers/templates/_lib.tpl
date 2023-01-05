{{/*
Expand the name of the chart.
*/}}
{{- define "ibm-embed-helpers.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ibm-embed-helpers.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a fully qualified app name to use as a prefix for created resources.

If release name contains chart name it will be used as the full name.

Some Kubernetes name fields are limited to 63 chars by the DNS naming spec.
Truncate to 30 here to leave space for component names and generated suffixes.
*/}}
{{- define "ibm-embed-helpers.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 30 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 30 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 30 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "ibm-embed-helpers.componentName" -}}
  {{- $params := . -}}
  {{- $root := index $params 0 -}}
  {{- $compName := index $params 1 -}}

  {{- printf "%s-%s" (include "ibm-embed-helpers.fullname" $root) $compName -}}
{{- end -}}

{{/*
Resource labels
*/}}
{{- define "ibm-embed-helpers.labels" -}}
  {{- $params := . -}}
  {{- $root := index $params 0 -}}
  {{- $compName := index $params 1 -}}
helm.sh/chart: "{{ include "ibm-embed-helpers.chart" $root }}"
{{ include "ibm-embed-helpers.selectorLabels" (list $root $compName) }}
app.kubernetes.io/version: "{{ $root.Chart.AppVersion }}"
app.kubernetes.io/managed-by: "{{ $root.Release.Service }}"
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ibm-embed-helpers.selectorLabels" -}}
  {{- $params := . -}}
  {{- $root := index $params 0 -}}
  {{- $compName := index $params 1 -}}
app.kubernetes.io/name: "{{ include "ibm-embed-helpers.name" $root }}"
app.kubernetes.io/instance: "{{ $root.Release.Name }}"
  {{- if $compName }}
app.kubernetes.io/component: "{{ $compName }}"
  {{- end }}
{{- end }}

{{/*
Image reference with optional tag and digest
*/}}
{{- define "ibm-embed-helpers.imageReference" -}}
  {{- $params := . -}}
  {{- $root := index $params 0 -}}
  {{- $imageConfig := index $params 1 -}}

  {{- $registry := $root.Values.containerRegistry -}}

  {{- with $imageConfig -}}
    {{- printf "%s/%s" $registry .repository -}}
    {{- if .tag -}}
      {{- printf ":%s" .tag -}}
    {{- end -}}
    {{- if .digest -}}
      {{- printf "@%s" .digest -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Common Restrictive Security Contexts
*/}}
{{- define "ibm-embed-helpers.containerSecurityContext" -}}
  {{- $root := . -}}
  {{- $readOnly := true -}}
  {{- if hasKey .Values "readOnlyRootFilesystem" -}}
    {{- $readOnly = .Values.readOnlyRootFilesystem -}}
  {{- end -}}

  {{- "securityContext:" -}}
    {{- "allowPrivilegeEscalation: false" | nindent 2 -}}
    {{- "capabilities:" | nindent 2 -}}
      {{- "drop:" | nindent 4 -}}
      {{- "- ALL" | nindent 4 -}}
    {{- "privileged: false" | nindent 2 -}}
    {{- (printf "readOnlyRootFilesystem: %v" $readOnly) | nindent 2 -}}
    {{- "runAsNonRoot: true" | nindent 2 -}}
  {{- "\n" -}}
{{- end -}}

{{- define "ibm-embed-helpers.podSecurityContext" -}}
  {{- "hostIPC: false" | nindent 0 -}}
  {{- "hostNetwork: false" | nindent 0 -}}
  {{- "hostPID: false" | nindent 0 -}}
  {{- "securityContext:" | nindent 0 -}}
    {{- "runAsNonRoot: true" | nindent 2 -}}
  {{- "\n" -}}
{{- end -}}

{{- define "ibm-embed-helpers.enabledModelImageConfigs" -}}
  {{- $images := list -}}
  {{- range $models := .Values.models -}}
    {{- if .enabled -}}
      {{- $images = (append $images .) -}}
    {{- end -}}
  {{- end -}}

  {{- $images | toYaml -}}
{{- end -}}

{{/*
Required configurations

NB: the result of `required` is piped through `regexReplaceAll` to remove all
content from the result to avoid errors like:
  error unmarshaling JSON: json: cannot unmarshal string into Go value of type releaseutil.SimpleHead
*/}}
{{- define "ibm-embed-helpers.requireObjectStorage" -}}
  {{- $message := "Configuration for s3 compatible storage is required in .Values.objectStorage, missing %s" -}}
  {{- required (printf $message `'endpoint'`) .Values.objectStorage.endpoint | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'region'`) .Values.objectStorage.region | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'accessKey'`) .Values.objectStorage.accessKey | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'secretKey'`) .Values.objectStorage.secretKey | regexReplaceAll ".+" "" -}}
{{- end }}

{{- define "ibm-embed-helpers.requirePostgres" -}}
  {{- $message := "Configuration for a PostgreSQL databse is required in .Values.postgres, missing %s" -}}
  {{- required (printf $message `'host'`) .Values.postgres.host | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'port'`) .Values.postgres.port | quote | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'loginDatabase'`) .Values.postgres.loginDatabase | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'user'`) .Values.postgres.user | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'password'`) .Values.postgres.password | regexReplaceAll ".+" "" -}}
  {{- required (printf $message `'databaseName'`) .Values.postgres.databaseName | regexReplaceAll ".+" "" -}}
{{- end }}
