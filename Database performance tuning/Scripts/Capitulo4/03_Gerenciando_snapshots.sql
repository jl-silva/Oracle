-- consultar snapshots
SELECT    snap_id, begin_interval_time, end_interval_time 
FROM      dba_hist_snapshot 
ORDER BY  1;

-- criar snapshots
EXEC dbms_workload_repository.create_snapshot;

-- APAGAR SNAPSHOTS
exec dbms_workload_repository.drop_snapshot_range(32,33);


