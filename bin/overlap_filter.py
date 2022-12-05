#!/usr/bin/env python3

import sys
import pandas as pd

from pathlib import Path

args = sys.argv[1:]

comparison = args[0]
rmats_only = Path(args[1])
overlap = Path(args[2])
whippet_only = Path(args[3])
rmats_min_diff = float(args[4])
whippet_min_diff = float(args[5])
min_fdr = float(args[6])
min_prob = float(args[7])

# Read data
rmats_only_df = pd.read_csv(rmats_only)
overlap_df = pd.read_csv(overlap)
whippet_only_df = pd.read_csv(whippet_only)

# Filter rMATS only results
rmats_only_filtered = rmats_only_df[
    (abs(rmats_only_df["inc_level_diff"]) >= rmats_min_diff)
    & (rmats_only_df["fdr"] <= min_fdr)
]

# Filter overlap results
overlap_df_filtered = overlap_df[
    (abs(overlap_df["rmats_inc_level_diff"]) >= rmats_min_diff)
    & (overlap_df["rmats_fdr"] <= min_fdr)
    & (abs(overlap_df["whippet_deltapsi"]) >= whippet_min_diff)
    & (overlap_df["whippet_probability"] >= min_prob)
]

# Filter Whippet only results
whippet_only_filtered = whippet_only_df[
    (abs(whippet_only_df["DeltaPsi"] >= whippet_min_diff))
    & (whippet_only_df["Probability"] >= min_prob)
]

# Write filtered results
rmats_only_filtered.to_csv(f"{comparison}.significant.rmats_only.csv", index=False)
overlap_df_filtered.to_csv(f"{comparison}.significant.rw_overlap.csv", index=False)
whippet_only_filtered.to_csv(f"{comparison}.significant.whippet_only.csv", index=False)
