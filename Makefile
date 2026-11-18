.PHONY: lint fix

lint:
	sqlfluff lint oss_pulse/models

fix:
	sqlfluff fix oss_pulse/models