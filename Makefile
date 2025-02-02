.PHONY: clean-pyc clean-build docs

help:
	@echo "clean-build - remove build artifacts"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "lint - check style with flake8"
	@echo "lint-roll - automatically fix problems with isort, flake8, etc"
	@echo "test - run tests quickly with the default Python"
	@echo "test-all - run tests on every Python version with tox"
	@echo "release - package and upload a release"
	@echo "dist - package"

clean: clean-build clean-pyc

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -rf {} +

lint:
	tox -e lint

lint-roll:
	isort eth_bloom tests
	black eth_bloom tests setup.py
	$(MAKE) lint

test:
	pytest tests

test-all:
	tox

check-bump:
ifndef bump
	$(error bump must be set, typically: major, minor, patch, or devnum)
endif

release: check-bump clean
	# require that you be on a branch that's linked to upstream/master
	git status -s -b | head -1 | grep "\.\.upstream/master"
	CURRENT_SIGN_SETTING=$(git config commit.gpgSign)
	git config commit.gpgSign true
	bumpversion $(bump)
	git push upstream && git push upstream --tags
	python -m build
	twine upload dist/*
	git config commit.gpgSign "$(CURRENT_SIGN_SETTING)"

dist: clean
	python -m build
	ls -l dist
