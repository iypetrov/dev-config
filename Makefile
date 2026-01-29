run:
	@bash main.sh

encrypt:
	@ansible-vault encrypt work_repos.sh

decrypt:
	@ansible-vault decrypt work_repos.sh
	@chmod +x work_repos.sh
