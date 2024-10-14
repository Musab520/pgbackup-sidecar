DOCKER_REGISTRY=musab520
BACKUP_DOCKER_REPOSITORY=$(DOCKER_REGISTRY)/pgbackup-sidecar
DOCKER_TAG=latest

package-backup:
	docker build --no-cache --quiet -t $(BACKUP_DOCKER_REPOSITORY):$(DOCKER_TAG) .

publish-backup:
	docker push --quiet $(BACKUP_DOCKER_REPOSITORY):$(DOCKER_TAG)

dev-dirs:
	mkdir -p -m 775 .dev/.data/dumps
	mkdir -p -m 775 .dev/.data/postgres

delete-dev-dirs:
	rm -rf .dev/.data/*

package: package-backup

publish: publish-backup

dev-stack: dev-dirs
	cd .dev && docker compose down --volumes --rmi local || true
	cd .dev && docker compose create --build --force-recreate --remove-orphans

clean-dev-stack: delete-dev-dirs delete-dev-stack dev-stack

run-dev-stack: dev-dirs
	cd .dev && docker compose start

stop-dev-stack:
	cd .dev && docker compose stop

delete-dev-stack:
	cd .dev && docker compose down