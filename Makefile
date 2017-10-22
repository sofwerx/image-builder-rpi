IMAGE := sofwerx/rpi-tpms:latest

default: build

build:
	docker pull $(IMAGE) || true
	docker build --cache-from $(IMAGE) -t $(IMAGE) .

sd-image: build
	docker run --rm --privileged -v $(shell pwd):/workspace -v /boot:/boot -v /lib/modules:/lib/modules -e TRAVIS_TAG -e VERSION $(IMAGE)

shell: build
	docker run -ti --privileged -v $(shell pwd):/workspace -v /boot:/boot -v /lib/modules:/lib/modules -e TRAVIS_TAG -e VERSION $(IMAGE) bash

test:
	VERSION=dirty docker run --rm -ti --privileged -v $(shell pwd):/workspace -v /boot:/boot -v /lib/modules:/lib/modules -e TRAVIS_TAG -e VERSION $(IMAGE) bash -c "unzip /workspace/rpi-tpms-dirty.img.zip && rspec --format documentation --color /workspace/builder/test/*_spec.rb"

shellcheck: build
	VERSION=dirty docker run --rm -ti -v $(shell pwd):/workspace $(IMAGE) bash -c 'shellcheck /workspace/builder/*.sh /workspace/builder/files/etc/firstboot.d/*'

vagrant:
	vagrant up

docker-machine: vagrant
	docker-machine create -d generic \
	  --generic-ssh-user $(shell vagrant ssh-config | grep ' User ' | cut -d ' ' -f 4) \
	  --generic-ssh-key $(shell vagrant ssh-config | grep IdentityFile | cut -d ' ' -f 4) \
	  --generic-ip-address $(shell vagrant ssh-config | grep HostName | cut -d ' ' -f 4) \
	  --generic-ssh-port $(shell vagrant ssh-config | grep Port | cut -d ' ' -f 4) \
	  $(IMAGE)

test-integration: test-integration-image test-integration-docker

test-integration-image:
	docker run --rm -ti -v $(shell pwd)/builder/test-integration:/serverspec:ro -e BOARD uzyexe/serverspec:2.24.3 bash -c "rspec --format documentation --color spec/hypriotos-image"

test-integration-docker:
	docker run --rm -ti -v $(shell pwd)/builder/test-integration:/serverspec:ro -e BOARD uzyexe/serverspec:2.24.3 bash -c "rspec --format documentation --color spec/hypriotos-docker"

tag:
	git tag ${TAG}
	git push origin ${TAG}
