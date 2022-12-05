process overlap {
  container { params.containers.python }
  publishDir { "$params.outputdir/overlap/" }, mode: 'copy'
  label 'sm'

  input:
  tuple val(comparison), path(rmatsdiff), path(whippetdelta)

  output:
  tuple val(comparison), path('*.rmats_only.csv'), path('*.rw_overlap.csv'), path('*.whippet_only.csv'), emit: data

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

process overlap_filter {
  container { params.containers.python }
  publishDir { "$params.outputdir/overlap/" }, mode: 'copy'
  label 'sm'

  input:
  tuple val(comparison), path(rmats), path(overlap), path(whippet)

  output:
  tuple val(comparison),
   path('*.significant.rmats_only.csv'),
   path('*.significant.rw_overlap.csv'),
   path('*.significant.whippet_only.csv'),
   emit: data

  script:
  """
  overlap_filter.py $comparison \\
    $rmats \\
    $overlap \\
    $whippet \\
    $params.rmats.mindiff \\
    $params.whippet.mindiff \\
    $params.rmats.maxfdr \\
    $params.whippet.minprob
  """

  stub:
  """
  echo overlap_filter.py $comparison \\
    $rmats \\
    $overlap \\
    $whippet \\
    $params.rmats.mindiff \\
    $params.whippet.mindiff \\
    $params.rmats.maxfdr \\
    $params.whippet.minprob > ${comparison}.significant.rmats_only.csv
  touch ${comparison}.significant.rw_overlap.csv
  touch ${comparison}.significant.whippet_only.csv
  """
}