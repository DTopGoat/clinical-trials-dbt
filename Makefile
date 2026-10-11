VENV ?= .venv
PY := $(VENV)/bin/python
DBT := $(VENV)/bin/dbt
export DBT_PROFILES_DIR := .

.PHONY: all setup extract build docs export insights lint clean
all: setup build export

setup:
	python3 -m venv $(VENV) && $(PY) -m pip install -q -r requirements.txt && $(DBT) deps

extract:            ## re-pull raw data from the ClinicalTrials.gov API
	$(PY) extract/extract_ctgov.py

build:
	$(DBT) build

docs:
	$(DBT) docs generate && $(DBT) docs serve

export:
	$(PY) scripts/export_marts.py

insights:
	$(PY) -c "import duckdb;c=duckdb.connect('clinical_trials.duckdb',read_only=True);[print(c.sql(q)) for q in open('scripts/insights.sql').read().split(';') if q.strip()]"

lint:
	$(VENV)/bin/sqlfluff lint models tests

clean:
	$(DBT) clean; rm -f clinical_trials.duckdb
