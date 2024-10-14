DOCKER_REGISTRY=musab520
BACKUP_DOCKER_REPOSITORY=$(DOCKER_REGISTRY)/pgbackup-sidecar
DOCKER_TAG=latest

package-backup:
	docker build --no-cache --quiet -t $(BACKUP_DOCKER_REPOSITORY):$(DOCKER_TAG) -f backup.dockerfle .

publish-backup:
	docker push --quiet $(BACKUP_DOCKER_REPOSITORY):$(DOCKER_TAG)

dev-dirs:
	mkdir -p -m 775 .dev/.data/dumps
	mkdir -p -m 775 .dev/.data/postgres

delete-dev-dirs:
	rm -rf .dev/.data/*

package: package-backup

publish: publish-backup

sidecar-stack: dev-dirs
	cd .dev && docker compose down --volumes --rmi local || true
	cd .dev && docker compose create --build --force-recreate --remove-orphans

clean-sidecar-stack: delete-dev-dirs delete-sidecar-stack sidecar-stack

run-sidecar-stack: dev-dirs
	cd .dev && docker compose start

stop-sidecar-stack:
	cd .dev && docker compose stop

delete-sidecar-stack:
	cd .dev && docker compose down