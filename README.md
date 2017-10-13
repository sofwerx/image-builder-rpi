# rpi-tpms

The goal of this repo is to produce a resultant raspberry-pi image that has the following installed and pre-configured:

- TPMS tire sensor data acquired via rtl433
- Optional webcam image acquisition -> web accessible object store (minio?)
- Logstash / Fluentd / IOT post of TPMS data + image URL
- ElasticSearch
- Kibana
- Grafana

# CI

This was forked from the hypriot/image-builder-rpi github project to adopt the same travis-ci based builds using docker.

