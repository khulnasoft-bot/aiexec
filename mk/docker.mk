######################
# DOCKER TARGETS
######################

docker_build: dockerfile_build clear_dockerimage ## build DockerFile

docker_build_backend: dockerfile_build_be clear_dockerimage ## build Backend DockerFile

docker_build_frontend: dockerfile_build_fe clear_dockerimage ## build Frontend Dockerfile

dockerfile_build:
	@echo 'BUILDING DOCKER IMAGE: ${DOCKERFILE}'
	@command -v $(DOCKER) >/dev/null 2>&1 || { echo "Error: $(DOCKER) is not installed. Please install $(DOCKER), or run 'make docker_build DOCKER=podman' (or DOCKER=docker) if you have an alternative installed."; exit 1; }
	@$(DOCKER) build --rm \
		-f ${DOCKERFILE} \
		-t primeagent:${VERSION} .

dockerfile_build_be: dockerfile_build
	@echo 'BUILDING DOCKER IMAGE BACKEND: ${DOCKERFILE_BACKEND}'
	@command -v $(DOCKER) >/dev/null 2>&1 || { echo "Error: $(DOCKER) is not installed. Please install $(DOCKER), or run 'make docker_build_backend DOCKER=podman' (or DOCKER=docker) if you have an alternative installed."; exit 1; }
	@$(DOCKER) build --rm \
		--build-arg PRIMEAGENT_IMAGE=primeagent:${VERSION} \
		-f ${DOCKERFILE_BACKEND} \
		-t primeagent_backend:${VERSION} .

dockerfile_build_fe: dockerfile_build
	@echo 'BUILDING DOCKER IMAGE FRONTEND: ${DOCKERFILE_FRONTEND}'
	@command -v $(DOCKER) >/dev/null 2>&1 || { echo "Error: $(DOCKER) is not installed. Please install $(DOCKER), or run 'make docker_build_frontend DOCKER=podman' (or DOCKER=docker) if you have an alternative installed."; exit 1; }
	@$(DOCKER) build --rm \
		--build-arg PRIMEAGENT_IMAGE=primeagent:${VERSION} \
		-f ${DOCKERFILE_FRONTEND} \
		-t primeagent_frontend:${VERSION} .

clear_dockerimage:
	@echo 'Clearing the docker build'
	@if $(DOCKER) images -f "dangling=true" -q | grep -q '.*'; then \
		$(DOCKER) rmi $$($(DOCKER) images -f "dangling=true" -q); \
	fi

docker_compose_up: docker_build docker_compose_down
	@echo 'Running docker compose up'
	$(DOCKER) compose -f $(DOCKER_COMPOSE) up --remove-orphans

docker_compose_down:
	@echo 'Running docker compose down'
	$(DOCKER) compose -f $(DOCKER_COMPOSE) down || true

dcdev_up:
	@echo 'Running docker compose up'
	$(DOCKER) compose -f docker/dev.docker-compose.yml down || true
	$(DOCKER) compose -f docker/dev.docker-compose.yml up --remove-orphans
