#!/usr/bin/env python3

import sys
import pandas as pd

from pathlib import Path

args = sys.argv[1:]
comparison = args[0]
whippet_res = Path(args[1])
min_diff = float(args[2])
min_prob = float(args[3])

# Construct output file name
output_file = f"{comparison}.significant.tsv"

# Read results
res_df = pd.read_table(whippet_res, index_col=False)

# Filter results
res_df_filtered = res_df[
    (abs(res_df["DeltaPsi"]) >= min_diff) & (res_df["Probability"] >= min_prob)
]

# Write filtered results
res_df_filtered.to_csv(output_file, sep="\t", index=False)
