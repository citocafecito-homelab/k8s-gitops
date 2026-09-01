{{- with secret "secret/data/frigate" -}}
mqtt:
  enabled: true
  host: mosquitto.home-assistant.svc.cluster.local
  port: 1883
  topic_prefix: frigate
  client_id: frigate

ffmpeg:
  hwaccel_args: preset-vaapi

auth:
  enabled: false

record:
  enabled: false

ui:
  timezone: America/Bogota

cameras:
  {{- range $name, $cam := .Data.data.cameras }}
  {{ $name }}:
    enabled: {{ if ne (index $cam "enabled") nil }}{{ $cam.enabled }}{{ else }}true{{ end }}
    ffmpeg:
      inputs:
        - path: rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream1
          roles:
            - record
        - path: rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream2
          roles:
            - detect
    live:
      height: 1080
      quality: 8

    detect:
      width: {{ or $cam.width 1280 }}
      height: {{ or $cam.height 720 }}
      fps: {{ or $cam.fps 5 }}
      enabled: {{ if ne (index $cam "detect") nil }}{{ $cam.detect }}{{ else if ne (index $cam "detect_enabled") nil }}{{ $cam.detect_enabled }}{{ else }}true{{ end }}

    objects:
      track:
        - person
        - dog
        - cat
      filters:
        person:
          min_score: 0.80
          threshold: 0.85
        dog:
          min_score: 0.70
          min_area: 2500
        cat:
          min_score: 0.55
  {{- end }}
{{- end }}