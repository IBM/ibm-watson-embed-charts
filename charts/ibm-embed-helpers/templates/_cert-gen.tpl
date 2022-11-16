{{/*
Generate TLS certificate signed by a CA
*/}}
{{- define "ibm-embed-helpers.genCert" -}}
  {{- $params := . -}}
  {{- $ca := index $params 0 -}}
  {{- $altNames := index $params 1 -}}

  {{- $cert := genSignedCert "ibm-watson-embed" nil $altNames 3650 $ca -}}
  {{- $cert | toJson -}}
{{- end -}}

{{/*
Print TLS certificate data as ConfigMap stringData
*/}}
{{- define "ibm-embed-helpers.certStringdata" -}}
  {{- $params := . -}}
  {{- $ca := index $params 0 -}}
  {{- $cert := index $params 1 -}}
  {{- "tls.crt: |" | nindent 2 -}}
  {{- $cert.Cert | nindent 4 -}}
  {{- "tls.key: |" | nindent 2 -}}
  {{- $cert.Key | nindent 4 -}}
  {{- "ca.crt: |" | nindent 2 -}}
  {{- $ca.Cert | nindent 4 -}}
  {{- "\n" -}}
{{- end -}}
