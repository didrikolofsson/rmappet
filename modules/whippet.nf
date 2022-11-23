process whippet_index {
  container { params.containers.whippet }

  input:
  path genome
  path annotation

  output:
  path 'index', emit: index

  script:
  """
  mkdir index
  julia /code/whippet/bin/whippet-index.jl \
    --fasta $genome \
    --gtf $annotation \
    -x index/graph \
    --suppress-low-tsl
  """

  stub:
  """
  mkdir index
  echo julia /code/whippet/bin/whippet-index.jl \\
    --fasta $genome \\
    --gtf $annotation \\
    -x index/graph \\
    --suppress-low-tsl \\
    > index/command.txt
  """
}

process whippet_quant {
  publishDir { "${params.outputdir}/whippet/quant" }, mode: 'copy'
  container { params.containers.whippet }

  input:
  path index
  tuple val(sampleID), path(reads), val(condition)

  output:
  tuple val(sampleID), path('*.psi.gz'), val(condition), emit: psi
  path '*.gene.tpm.gz',                                  emit: gene_tpm
  path '*.isoform.tpm.gz',                               emit: isoform_tpm
  path '*.jnc.gz',                                       emit: junctions
  path '*.map.gz',                                       emit: map

  script:
  """
  julia /code/whippet/bin/whippet-quant.jl \\
    $reads \\
    -o $sampleID \\
    -x index/graph.jls
  """

  stub:
  """
  echo julia /code/whippet/bin/whippet-quant.jl \\
    $reads \\
    -o $sampleID \\
    -x index/graph.jls \\
    > ${sampleID}.psi.gz
  touch ${sampleID}.gene.tpm.gz
  touch ${sampleID}.isoform.tpm.gz
  touch ${sampleID}.jnc.gz
  touch ${sampleID}.map.gz
  """
}

process whippet_delta {
  publishDir { "${params.outputdir}/whippet/delta" }, mode: 'copy'
  container { params.containers.whippet }

  input:
  tuple val(conditions), path(condition_a_quants), path(condition_b_quants)

  output:
  path '*.diff.gz', emit: data

  script:
  condition_a = conditions.condition_a
  condition_b = conditions.condition_b
  quants_a_joined = condition_a_quants.join(',')
  quants_b_joined = condition_b_quants.join(',')
  """
  julia /code/whippet/bin/whippet-delta.jl \\
    -a $quants_a_joined \\
    -b $quants_b_joined \\
    -o ${condition_a}_vs_${condition_b} \\
    -s 2
  """

  stub:
  condition_a = conditions.condition_a
  condition_b = conditions.condition_b
  quants_a_joined = condition_a_quants.join(',')
  quants_b_joined = condition_b_quants.join(',')
  """
  echo julia /code/whippet/bin/whippet-delta.jl \\
    -a $quants_a_joined \\
    -b $quants_b_joined \\
    -o ${condition_a}_vs_${condition_b} \\
    -s 2 \\
    > ${condition_a}_vs_${condition_b}.diff.gz
  """
}