process whippet_index {
  container { params.containers.whippet }
  label 'lg'

  input:
  path genome
  path annotation

  output:
  path 'index', emit: index

  script:
  if ( workflow.profile.contains('singularity') ) {
    extra = "julia --project=/code/whippet/ -e 'using Pkg; Pkg.instantiate()'"
  } else {
    extra = ""
  }
  """
  $extra
  mkdir index
  whippet-index.jl \
    --fasta $genome \
    --gtf $annotation \
    -x index/graph \
    --suppress-low-tsl
  """

  stub:
  """
  mkdir index
  echo whippet-index.jl \\
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
  label 'md'

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
  whippet-quant.jl \\
    $reads \\
    -o $sampleID \\
    -x index/graph.jls
  """

  stub:
  """
  echo whippet-quant.jl \\
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
  label 'md'

  input:
  tuple val(conditions), path(condition_a_quants), path(condition_b_quants)

  output:
  tuple val(comparison), path('*.diff.gz'), emit: delta

  script:
  comparison = "${conditions.a}_vs_${conditions.b}"
  quants_a_joined = condition_a_quants.join(',')
  quants_b_joined = condition_b_quants.join(',')
  """
  whippet-delta.jl \\
    -a $quants_a_joined \\
    -b $quants_b_joined \\
    -o $comparison \\
    -s 2
  """

  stub:
  comparison = "${conditions.a}_vs_${conditions.b}"
  quants_a_joined = condition_a_quants.join(',')
  quants_b_joined = condition_b_quants.join(',')
  """
  echo whippet-delta.jl \\
    -a $quants_a_joined \\
    -b $quants_b_joined \\
    -o $comparison \\
    -s 2 \\
    > ${comparison}.diff.gz
  """
}