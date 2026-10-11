"""Export mart tables to exports/ as CSV and Parquet for dashboard use."""
import os, duckdb
DB = os.environ.get("DUCKDB_PATH", "clinical_trials.duckdb")
OUT = os.path.join(os.path.dirname(__file__), "..", "exports")
os.makedirs(OUT, exist_ok=True)
con = duckdb.connect(DB, read_only=True)
tables = [r[0] for r in con.sql(
    "select table_name from information_schema.tables where table_schema='marts' order by 1").fetchall()]
for t in tables:
    con.sql(f"copy (select * from marts.{t} order by all) to '{OUT}/{t}.csv' (header)")
    con.sql(f"copy (select * from marts.{t} order by all) to '{OUT}/{t}.parquet' (format parquet)")
    print(f"{t}: {con.sql(f'select count(*) from marts.{t}').fetchone()[0]} rows")
