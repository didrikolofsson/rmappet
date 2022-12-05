process rmats_run {
    container { params.containers.rmats }
    publishDir { "$params.outputdir/rmats/run/" }, mode: 'copy'
    label 'md'
    
    input:
    tuple val(conditions), path(condition_a_bams), path(condition_b_bams)
    path annotation

    output:
    tuple val(comparison), path("$comparison"), emit: data

    script:
    comparison = "${conditions.a}_vs_${conditions.b}"
    a_bams_joined = condition_a_bams.join(",")
    b_bams_joined = condition_b_bams.join(",")
    """
    echo $a_bams_joined > ${conditions.a}.txt
    echo $b_bams_joined > ${conditions.b}.txt
    
    mkdir -p $comparison
    rmats.py \\
        --b1 ${conditions.a}.txt \\
        --b2 ${conditions.b}.txt \\
        --novelSS \\
        -t $params.libtype \\
        --readLength $params.readlen \\
        --variable-read-length \\
        --gtf $annotation  \\
        --nthread $task.cpus \\
        --od $comparison \\
        --tmp ${comparison}/tmp
    
    rm -r ${comparison}/tmp
    """

		stub:
    comparison = "${conditions.a}_vs_${conditions.b}"
    a_bams_joined = condition_a_bams.join(",")
    b_bams_joined = condition_b_bams.join(",")
    """
    echo $a_bams_joined > ${conditions.a}.txt
    echo $b_bams_joined > ${conditions.b}.txt
    
    mkdir -p $comparison
    echo rmats.py \\
			--b1 ${conditions.a}.txt \\
			--b2 ${conditions.b}.txt \\
			--novelSS \\
			-t $params.libtype \\
			--readLength $params.readlen \\
			--variable-read-length \\
			--gtf $annotation  \\
			--nthread $task.cpus \\
			--od $comparison \\
			--tmp ${comparison}/tmp \\
			> ${comparison}/${comparison}.txt
    """
}

process rmats_parse_coords {
    container { params.containers.python }
    publishDir { "${params.outputdir}/rmats/results" }, mode: 'copy'
    label 'sm'

    input:
    tuple val(comparison), path(data)

    output:
    tuple val(comparison), path('*.jcec.tsv'), path('*.jc.tsv'), emit: data

    script:
    """
    rmats_parse_coords.py $data $comparison
    """

		stub:
    """
    echo rmats_parse_coords.py \\
			$data \\
			$comparison \\
			> ${comparison}.jcec.tsv
		touch ${comparison}.jc.tsv
    """
}

process rmats_filter {
    container { params.containers.python }
    publishDir { "${params.outputdir}/rmats/results" }, mode: 'copy'
    label 'sm'

    input:
    tuple val(comparison), path(jcec), path(jc)

    output:
    tuple val(comparison), path('*.significant.jcec.tsv'), path('*.significant.jc.tsv')

    script:
    """
    rmats_filter.py \\
      $comparison \\
      $jcec \\
      $jc \\
      $params.rmats.mindiff \\
      $params.rmats.maxfdr
    """

		stub:
    """
    echo rmats_filter.py \\
      $comparison \\
      $jcec \\
      $jc \\
      $params.rmats.mindiff \\
      $params.rmats.maxfdr > ${comparison}.significant.jcec.tsv
    touch ${comparison}.significant.jc.tsv
    """
}