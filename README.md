# rpi-tpms

[![Build Status](https://travis-ci.org/sofwerx/rpi-tpms.svg)](https://travis-ci.org/sofwerx/rpi-tpms)

The goal of this repo is to produce a resultant raspberry-pi image that has the following installed and pre-configured:

- TPMS tire sensor data acquired via rtl433
- Optional webcam image acquisition -> web accessible object store (minio?)
- Publish TPMS sensor data to MQTT service
- Gateway MQTT messages to Elasticsearch
- ElasticSearch
- Kibana

# Usage:

Download the `rpi-tpms-${VERSION}.img.zip` file from the [Releases](https://github.com/sofwerx/rpi-tpms/releases) section of this github repository.

Unzip the `.zip` file, flash the `.img` file to SDCARD and place it in your Raspberry-Pi.

After booting, login to the Raspberry-Pi at the console or over ssh with a login username of `pi` and a login password of `raspberry`.

Then run the following:

    cd /tpms
    docker-compose up -d

That should pull all of the docker images and start the containers.

