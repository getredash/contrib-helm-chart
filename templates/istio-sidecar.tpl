{{- define "redash-istio-sidecar" -}}
  {{- $identifier := "redash" -}}

resources:
  sidecars:
    main:   # TODO: review this ?
      workloadLabels:
        app.kubernetes.io/component: TODO-flo

      blockUndefinedOutbound: {{ .Values.istio.blockUndefinedDependencies }}
      egress:
        - hosts:
            {{- range $egressListener, $params := .Values.istio.dependencies }}
              {{-  if contains "/" $egressListener }}
                {{- printf "- %s" $egressListener | nindent 12 }}
              {{- else }}
                {{- printf "- \"*/%s\"" $egressListener | nindent 12 }}
              {{- end }}
            {{- end }}
{{- end -}}
{{- $_ := mergeOverwrite .Values (include "redash-istio-sidecar" . | fromYaml) }}
