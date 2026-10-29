# Deferred items: Phase 01.1

| Found during | Item | Evidence | Why deferred |
|---|---|---|---|
| 01.1-01 | A scheduled `ci` run on main `2d2bbe0` failed the `security` job. The log line is "Failed to fetch record for mime from registry (using cache instead)", then exit 1. | https://github.com/szTheory/fablebook/actions/runs/40812122621 | It predates this plan, and no file in this plan touches it. The PR run and the post-merge main run both passed `security`. Check whether the nightly audit step should tolerate a transient registry fetch, without lowering the gate. |
