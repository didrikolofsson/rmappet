process fastp {
  container { params.containers.fastp }
  publishDir path: { "$params.outputdir/fastp/" },
    mode: 'copy',
    saveAs: { filename -> filename.endsWith(".trim.fq.gz") ? null: filename }

  input:
  tuple val(sampleID), path(reads), val(condition)

  output:
  tuple val(sampleID), path("*.trim.fq.gz"), val(condition), emit: reads
  path "*.fastp.json",                                       emit: json
  path "*.fastp.html",                                       emit: html

  script:
  if ( params.libtype == "single" ) {
    """
    fastp \\
      --in1 $reads \\
      --out1 ${sampleID}.trim.fq.gz \\
      --json ${sampleID}.fastp.json \\
      --html ${sampleID}.fastp.html \\
      --thread $task.cpus
    """
  } else if ( params.libtype == "paired" ) {
    """
    fastp \\
      --in1 ${reads[0]} --in2 ${reads[1]} \\
      --out1 ${sampleID}_1.trim.fq.gz --out2 ${sampleID}_2.trim.fq.gz \\
      --detect_adapter_for_pe \\
      --json ${sampleID}.fastp.json \\
      --html ${sampleID}.fastp.html \\
      --thread $task.cpus
    """
  }

  stub:
  if ( params.libtype == "single" ) {
    """
    touch ${sampleID}.trim.fq.gz
    echo fastp \\
      --in1 $reads \\
      --out1 ${sampleID}.trim.fq.gz \\
      --json ${sampleID}.fastp.json \\
      --html ${sampleID}.fastp.html \\
      --thread $task.cpus > ${sampleID}.fastp.json
    touch ${sampleID}.fastp.html
    """
  } else if ( params.libtype == "paired" ) {
    """
    touch ${sampleID}_1.trim.fq.gz ${sampleID}_2.trim.fq.gz
    echo fastp \\
      --in1 ${reads[0]} --in2 ${reads[1]} \\
      --out1 ${sampleID}_1.trim.fq.gz --out2 ${sampleID}_2.trim.fq.gz \\
      --detect_adapter_for_pe \\
      --json ${sampleID}.fastp.json \\
      --html ${sampleID}.fastp.html \\
      --thread $task.cpus > ${sampleID}.fastp.json
    touch ${sampleID}.fastp.html
    """
  }
}