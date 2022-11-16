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
  {{- $root := index . 0 -}}
  {{- $imageConfig := index . 1 -}}
    {{- with $imageConfig -}}
        {{- printf "%s/%s" $root.Values.containerRegistry .repository -}}
        {{- if .tag -}}
          {{- printf ":%s" .tag -}}
        {{- end -}}
        {{- if .digest -}}
          {{- printf "@%s" .digest -}}
        {{- end -}}
    {{- end -}}
{{- end }}

{{/*
Common Restrictive Security Contexts
*/}}
{{- define "ibm-embed-helpers.containerSecurityContext" -}}
  {{- "securityContext:" -}}
    {{- "allowPrivilegeEscalation: false" | nindent 2 -}}
    {{- "capabilities:" | nindent 2 -}}
      {{- "drop:" | nindent 4 -}}
      {{- "- ALL" | nindent 4 -}}
    {{- "privileged: false" | nindent 2 -}}
    {{- "readOnlyRootFilesystem: true" | nindent 2 -}}
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
