#!/usr/bin/env python3

import sys
import pandas as pd

from pathlib import Path

args = sys.argv[1:]
comparison = args[0]
path_dict = {"jcec": Path(args[1]), "jc": Path(args[2])}
min_diff = float(args[3])
max_fdr = float(args[4])

for k, v in path_dict.items():
    # Construct output file name
    output_file = f"{comparison}.significant.{k}.tsv"

    # Read results table
    res_df = pd.read_table(v)

    # Filter results
    res_df_filtered = res_df[
        (abs(res_df["inc_level_diff"]) >= min_diff) & (res_df["fdr"] <= max_fdr)
    ]

    # Write filtered results
    res_df_filtered.to_csv(output_file, sep="\t", index=False)
