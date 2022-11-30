process overlap {
  container { params.containers.python }
  publishDir { "$params.outputdir/overlap/" },
      mode: 'copy'
  label 'sm'

  input:
  tuple val(comparison), path(rmatsdiff), path(whippetdelta)

  output:
  path '*.rw_overlap.csv', emit: overlap
  path '*.rmats_only.csv', emit: rmats
  path '*.whippet_only.csv', emit: whippet

  script:
  """
  overlap.py $rmatsdiff $whippetdelta $comparison
  """

  stub:
  """
  echo overlap.py $rmatsdiff $whippetdelta $comparison > ${comparison}.rw_overlap.csv
  touch ${comparison}.rmats_only.csv
  touch ${comparison}.whippet_only.csv
  """
}
