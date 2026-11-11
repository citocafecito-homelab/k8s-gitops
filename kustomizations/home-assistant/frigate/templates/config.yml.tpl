{{- with secret "secret/data/frigate" -}}
mqtt:
  enabled: true
  host: mosquitto.home-assistant.svc.cluster.local
  port: 1883
  topic_prefix: frigate
  client_id: frigate

auth:
  enabled: false

record:
  enabled: true
  expire_interval: 60
  retain:
    days: 7
    mode: all
  events:
    pre_capture: 10
    post_capture: 15
    retain:
      default: 30
      mode: motion

ui:
  timezone: America/Bogota

go2rtc:
  streams:
    {{- range $name, $cam := .Data.data.cameras }}
    {{ $name }}:
      - rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream1
      - rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream2
    {{- end }}

cameras:
  {{- range $name, $cam := .Data.data.cameras }}
  {{ $name }}:
    enabled: {{ if ne (index $cam "enabled") nil }}{{ $cam.enabled }}{{ else }}true{{ end }}
    ffmpeg:
      inputs:
        - path: rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream1
          roles:
            - record
          hwaccel_args: preset-intel-qsv-h265
        - path: rtsp://{{ $cam.username }}:{{ $cam.password }}@{{ $cam.ip }}:{{ or $cam.port 554 }}/stream2
          roles:
            - detect

    live:
      height: 1440
      quality: 10

    detect:
      width: {{ or $cam.width 1280 }}
      height: {{ or $cam.height 720 }}
      fps: {{ or $cam.fps 5 }}
      enabled: {{ if ne (index $cam "detect") nil }}{{ $cam.detect }}{{ else }}true{{ end }}

    record:
      enabled: {{ if ne (index $cam "record") nil }}{{ $cam.record }}{{ else }}true{{ end }}
      retain:
        days: 7
        mode: motion
      events:
        required_zones: []
        pre_capture: 10
        post_capture: 10
        retain:
          default: 30
          mode: motion

    objects:
      track:
        {{- if $cam.track_objects }}
        {{- range $cam.track_objects }}
        - {{ . }}
        {{- end }}
        {{- else }}
        - person
        - dog
        - cat
        {{- end }}
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