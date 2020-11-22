deploy:
	@docker-compose run --rm web yarn build
	@terraform apply -auto-approve

.PHONY: deploy
