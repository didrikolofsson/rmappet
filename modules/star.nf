process star_index {
  container { params.containers.star }
  
  input:
  path genome
  path annotation

  output:
  path 'index', emit: index
  
  script:
  """
  mkdir -p index
  STAR \\
    --runMode genomeGenerate \\
    --genomeDir index/ \\
    --runThreadN $task.cpus \\
    --genomeFastaFiles $genome \\
    --sjdbGTFfile $annotation
  """

  stub:
  """
  mkdir -p index
  echo STAR \\
    --runMode genomeGenerate \\
    --genomeDir index/ \\
    --runThreadN $task.cpus \\
    --genomeFastaFiles $genome \\
    --sjdbGTFfile $annotation > index/command.txt
  """
}

process star_align {
  container { params.containers.star }
  publishDir path: { "${params.outputdir}/star/alignments/" },
    mode: 'copy',
    saveAs: { filename -> filename.endsWith(".bam") ? null: filename }

  input:
  path index
  tuple val(sampleID), path(reads), val(condition)
  
  output:
  tuple val(sampleID), path('*.Aligned.out.bam'), val(condition), emit: bam
  path '*.ReadsPerGene.out.tab',                                  emit: counts
  path '*.SJ.out.tab',                                            emit: junction
  path '*.Log.final.out',                                         emit: log

  script:
  """
  STAR \\
    --runThreadN $task.cpus \\
    --genomeDir $index \\
    --readFilesIn $reads \\
    --readFilesCommand zcat \\
    --outSAMtype BAM Unsorted \\
    --outFileNamePrefix ${sampleID}. \\
    --quantMode GeneCounts
  """

  stub:
  """
  touch ${sampleID}.Aligned.out.bam
  touch ${sampleID}.ReadsPerGene.out.tab
  touch ${sampleID}.SJ.out.tab
  echo STAR \\
    --runThreadN $task.cpus \\
    --genomeDir $index \\
    --readFilesIn $reads \\
    --readFilesCommand zcat \\
    --outSAMtype BAM Unsorted \\
    --outFileNamePrefix ${sampleID}. \\
    --quantMode GeneCounts \\
    > ${sampleID}.Log.final.out
  """
}