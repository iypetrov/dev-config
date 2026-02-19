run:
	@bash main.sh

encrypt:
	@ansible-vault encrypt private_repos.sh

decrypt:
	@ansible-vault decrypt private_repos.sh
	@chmod +x private_repos.sh
