process samtools_sort {
  container { params.containers.samtools }
  publishDir { "$params.outputdir/samtools/sort/" },
      mode: 'copy'

  input:
  tuple val(sampleID), path(bam), val(condition)

  output:
  tuple val(sampleID), path('*.sortedByCoord.bam*'), val(condition), emit: bam

  script:
  """
  samtools sort \\
    -l 4 \\
    -m 1G \\
    -o ${sampleID}.sortedByCoord.bam \\
    -O BAM \\
    -@ $task.cpus \\
    $bam
  samtools index ${sampleID}.sortedByCoord.bam
  """

  stub:
  """
  echo samtools sort \\
    -l 4 \\
    -m 1G \\
    -o ${sampleID}.sortedByCoord.bam \\
    -O BAM \\
    -@ $task.cpus \\
    $bam \\
    > ${sampleID}.sortedByCoord.bam
  echo samtools index ${sampleID}.sortedByCoord.bam > ${sampleID}.sortedByCoord.bam.bai
    """
}