#!/usr/bin/env python3

import re
import sys
import pandas as pd
from pathlib import Path
from collections import defaultdict


def parse_a3ss(x):
    if x.strand == "+":
        event_start = x.longExonStart_0base + 1
        event_end = x.shortES
    elif x.strand == "-":
        event_start = x.shortEE + 1
        event_end = x.longExonEnd

    coord = "{}:{}-{}".format(x.chr, event_start, event_end)
    flank = "{}:{}-{}".format(x.chr, x.flankingES, x.flankingEE)

    return coord, flank


def parse_a5ss(x):
    if x.strand == "+":
        event_start = x.shortEE + 1
        event_end = x.longExonEnd
    elif x.strand == "-":
        event_start = x.longExonStart_0base
        event_end = x.shortES
    coord = "{}:{}-{}".format(x.chr, event_start, event_end)
    flank = "{}:{}-{}".format(x.chr, x.flankingES, x.flankingEE)
    return coord, flank


def parse_mxe(x):
    coord = "{}:{}-{}:{}-{}".format(
        x.chr,
        x["1stExonStart_0base"] + 1,
        x["1stExonEnd"],
        x["2ndExonStart_0base"] + 1,
        x["2ndExonEnd"],
    )
    flank = "{chr}:{u_start}-{u_end},{chr}:{d_start}-{d_end}".format(
        chr=x.chr,
        u_start=x.upstreamES,
        u_end=x.upstreamEE,
        d_start=x.downstreamES,
        d_end=x.downstreamEE,
    )
    return coord, flank


def parse_ri(x):
    coord = "{}:{}-{}".format(x.chr, x.upstreamEE + 1, x.downstreamES)
    flank = "{chr}:{u_start}-{u_end},{chr}:{d_start}-{d_end}".format(
        chr=x.chr,
        u_start=x.upstreamES,
        u_end=x.upstreamEE,
        d_start=x.downstreamES,
        d_end=x.downstreamEE,
    )
    return coord, flank


def parse_se(x):
    coord = "{}:{}-{}".format(x.chr, x.exonStart_0base + 1, x.exonEnd)
    flank = "{chr}:{u_start}-{u_end},{chr}:{d_start}-{d_end}".format(
        chr=x.chr,
        u_start=x.upstreamES,
        u_end=x.upstreamEE,
        d_start=x.downstreamES,
        d_end=x.downstreamEE,
    )
    return coord, flank


p = Path(sys.argv[1])
rmats_output = sorted(p.glob("**/*.txt"))
rmats_output_filtered = [
    x for x in rmats_output if re.search("JC.txt|JCEC.txt", str(x))
]

rmats_data_dict = defaultdict(list)

for fp in rmats_output_filtered:
    event_type = fp.name.split(".")[0]
    output_type = fp.name.split(".")[-2].lower()
    rmats_df = pd.read_table(fp.resolve(), error_bad_lines=False)
    for idx, row in rmats_df.iterrows():
        if event_type == "A3SS":
            coord, flank = parse_a3ss(row)
        elif event_type == "A5SS":
            coord, flank = parse_a5ss(row)
        elif event_type == "MXE":
            coord, flank = parse_mxe(row)
        elif event_type == "SE":
            coord, flank = parse_se(row)
        elif event_type == "RI":
            coord, flank = parse_ri(row)
        rmats_data_dict[output_type].append(
            {
                "gene_id": row.GeneID,
                "gene_symbol": row.geneSymbol,
                "type": event_type,
                "coord": coord,
                "flank": flank,
                "strand": row.strand,
                "inc_form_len": row.IncFormLen,
                "skip_form_len": row.SkipFormLen,
                "p_value": row.PValue,
                "fdr": row.FDR,
                "inc_level_1": row.IncLevel1,
                "inc_level_2": row.IncLevel2,
                "inc_level_diff": row.IncLevelDifference,
            }
        )

comparison = sys.argv[2]
for k, v in rmats_data_dict.items():
    pd.DataFrame(v).to_csv(sep="\t", index=False, path_or_buf=f"{comparison}.{k}.tsv")
