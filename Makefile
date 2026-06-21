.PHONY: install check pacman paru aur zsh

install:
	./install.sh

check:
	./scripts/00-check-system.sh

pacman:
	./scripts/10-install-pacman.sh

paru:
	./scripts/20-install-paru.sh

aur:
	./scripts/30-install-aur.sh

zsh:
	./scripts/40-set-zsh.sh
