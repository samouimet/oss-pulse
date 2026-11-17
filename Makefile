.PHONY: lint fix

lint:
	sqlfluff lint oss_pulse/models

fix:
	sqlfluff fix --force oss_pulse/models