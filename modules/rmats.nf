process rmats_run {
    container { params.containers.rmats }
    publishDir { "$params.outputdir/rmats/run/" }, mode: 'copy'
    
    input:
    tuple val(conditions), path(condition_a_bams), path(condition_b_bams)
    path annotation

    output:
    tuple val(conditions), path("${conditions.a}_vs_${conditions.b}"), emit: data

    script:
    a_bams_joined = condition_a_bams.join(",")
    b_bams_joined = condition_b_bams.join(",")
    """
    echo $a_bams_joined > ${conditions.a}.txt
    echo $b_bams_joined > ${conditions.b}.txt
    
    mkdir -p ${conditions.a}_vs_${conditions.b}
    rmats.py \\
        --b1 ${conditions.a}.txt \\
        --b2 ${conditions.b}.txt \\
        --novelSS \\
        -t paired \\
        --readLength $params.read_length \\
        --variable-read-length \\
        --gtf $annotation  \\
        --nthread $task.cpus \\
        --od ${conditions.a}_vs_${conditions.b} \\
        --tmp ${conditions.a}_vs_${conditions.b}/tmp
    
    rm -r ${conditions.a}_vs_${conditions.b}/tmp
    """

		stub:
    a_bams_joined = condition_a_bams.join(",")
    b_bams_joined = condition_b_bams.join(",")
    """
    echo $a_bams_joined > ${conditions.a}.txt
    echo $b_bams_joined > ${conditions.b}.txt
    
    mkdir -p ${conditions.a}_vs_${conditions.b}
    echo rmats.py \\
			--b1 ${conditions.a}.txt \\
			--b2 ${conditions.b}.txt \\
			--novelSS \\
			-t paired \\
			--readLength $params.read_length \\
			--variable-read-length \\
			--gtf $annotation  \\
			--nthread $task.cpus \\
			--od ${conditions.a}_vs_${conditions.b} \\
			--tmp ${conditions.a}_vs_${conditions.b}/tmp \\
			> ${conditions.a}_vs_${conditions.b}/${conditions.a}_vs_${conditions.b}.txt
    """
}

process rmats_parse_coords {
    container { params.containers.python }
    publishDir { "${params.outputdir}/rmats/results" }, mode: 'copy'
    label 'sm'

    input:
    tuple val(conditions), path(data)

    output:
    tuple path('*.jcec.tsv'), path('*.jc.tsv'), emit: data

    script:
    """
    rmats_parse_coords.py $data ${conditions.a}_vs_${conditions.b}
    """

		stub:
    """
    echo rmats_parse_coords.py \\
			$data \\
			${conditions.a}_vs_${conditions.b} \\
			> ${conditions.a}_vs_${conditions.b}.jcec.tsv
		touch ${conditions.a}_vs_${conditions.b}.jc.tsv
    """
}