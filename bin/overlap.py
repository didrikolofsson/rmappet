#!/usr/bin/env python3

import re
import sys

import pandas as pd

from pathlib import Path
from interlap import InterLap
from collections import defaultdict


def translate_whippet_events(x):
    """
    Translate whippet events to standard vocabulary:
    CE = SE
    AA = A3SS
    AD = A5SS
    RI = RI
    """
    if x == "CE":
        return "SE"
    if x == "AA":
        return "A3SS"
    if x == "AD":
        return "A5SS"
    if x == "RI":
        return "RI"


def init_ranges():
    """
    Initiate nested defaultdict
    """
    return defaultdict(lambda: defaultdict(InterLap))


def split_coord(coord):
    """
    Split event coordinate to chromosome, start, end
    """
    chr, start, end = re.split(":|-", coord)
    return chr, int(start), int(end)


def get_window(i, n):
    """
    Create window around integer
    """
    return i - n, i + n


args = sys.argv[1:]

rmats_results = pd.read_table(args[0], index_col=False)
whippet_results = pd.read_table(args[1], index_col=False)

# Remove MXE from rMATS results
rmats_results_filter = rmats_results[rmats_results["type"] != "MXE"].copy()

# Remove Whippet sepcific event types and translate types to standard vocabulary
whippet_results_filter = whippet_results[
    (whippet_results["Type"] == "CE")
    | (whippet_results["Type"] == "AA")
    | (whippet_results["Type"] == "AD")
    | (whippet_results["Type"] == "RI")
].copy()

whippet_results_filter["Type"] = whippet_results_filter["Type"].apply(
    translate_whippet_events
)


ranges = init_ranges()
for idx, row in rmats_results_filter.iterrows():
    strand = row.strand
    chr, start, end = split_coord(row.coord)
    ranges[chr][strand].add(
        (start, end, {"gene": row.gene_symbol, "type": row.type, "flank": row.flank})
    )


results = list()
for idx, row in whippet_results_filter.iterrows():
    strand, event_type = row.Strand, row.Type
    chr, start, end = split_coord(row.Coord)
    start_window, end_window = get_window(start, 1), get_window(end, 1)
    ols = ranges[chr][strand].find((start, end))
    for ol in ols:
        if (start_window[0] <= ol[0] <= start_window[1]) and (
            end_window[0] <= ol[1] <= end_window[1]
        ):
            if event_type == ol[2]["type"]:
                results.append(
                    {
                        "rmats_flank": ol[2]["flank"],
                        "rmats_coord": f"{chr}:{ol[0]}-{ol[1]}",
                        "whippet_coord": f"{chr}:{start}-{end}",
                        "type": row.Type,
                        "strand": strand,
                    }
                )

overlaps_df = pd.DataFrame(results).drop_duplicates()

# Merge data from overlapping rMATS and Whippet results
rmats_overlap_merge = rmats_results.merge(
    overlaps_df,
    left_on="strand type coord flank".split(),
    right_on="strand type rmats_coord rmats_flank".split(),
    how="inner",
)

whippet_overlap_merge = (
    whippet_results_filter.merge(
        overlaps_df,
        left_on="Strand Type Coord".split(),
        right_on="strand type whippet_coord".split(),
        how="inner",
    )
    .drop_duplicates(subset="rmats_flank rmats_coord whippet_coord".split())
    .drop(columns="type strand".split())
)

main_overlap_merge = pd.merge(
    rmats_overlap_merge,
    whippet_overlap_merge,
    left_on="strand type rmats_flank rmats_coord whippet_coord".split(),
    right_on="Strand Type rmats_flank rmats_coord whippet_coord".split(),
    how="inner",
)

main_overlap_sliced = main_overlap_merge[
    """
gene_id gene_symbol strand type rmats_flank rmats_coord p_value fdr inc_level_1 
inc_level_2 inc_level_diff inc_form_len skip_form_len 
whippet_coord Probability Complexity Entropy Psi_A Psi_B DeltaPsi
""".split()
]

main_overlap_sliced.columns = """
gene_id gene_symbol strand type rmats_flank rmats_coord rmats_p_value rmats_fdr rmats_inc_level_1 
rmats_inc_level_2 rmats_inc_level_diff rmats_inc_form_len rmats_skip_form_len 
whippet_coord whippet_Probability whippet_Complexity whippet_Entropy whippet_Psi_A whippet_Psi_B whippet_DeltaPsi
""".lower().split()

# rMATS specific events
rmats_results_merge = rmats_results.merge(
    overlaps_df,
    left_on="strand type coord flank".split(),
    right_on="strand type rmats_coord rmats_flank".split(),
    how="outer",
    indicator=True,
)
rmats_only = rmats_results_merge[rmats_results_merge["_merge"] == "left_only"][
    "strand type coord flank".split()
]
rmats_results_only = rmats_results.merge(rmats_only, how="inner")

# Whippet specific events
whippet_results_merge = whippet_results.merge(
    overlaps_df,
    left_on="Strand Coord".split(),
    right_on="strand whippet_coord".split(),
    how="outer",
    indicator=True,
)

whippet_only = whippet_results_merge[whippet_results_merge["_merge"] == "left_only"][
    "Strand Type Coord".split()
]
whippet_results_only = whippet_results.merge(whippet_only, how="inner")

# Write data
main_overlap_sliced.drop_duplicates().to_csv(f"{args[2]}.rw_overlap.csv", index=False)
rmats_results_only.drop_duplicates().to_csv(f"{args[2]}.rmats_only.csv", index=False)
whippet_results_only.drop_duplicates().to_csv(
    f"{args[2]}.whippet_only.csv", index=False
)
