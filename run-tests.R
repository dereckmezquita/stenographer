#!/usr/bin/env Rscript

# First time to create snapshots
devtools::test(reporter = "progress")

# Review snapshots
testthat::snapshot_review()

# After reviewing, to accept the snapshots
testthat::snapshot_accept()