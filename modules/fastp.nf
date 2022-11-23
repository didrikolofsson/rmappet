process fastp {
  container { params.containers.fastp }
  publishDir path: { "$params.outputdir/fastp/" },
    mode: 'copy',
    saveAs: { filename -> filename.endsWith(".trim.fq.gz") ? null: filename }

  input:
  tuple val(sampleID), path(read1), path(read2), val(condition)

  output:
  tuple val(sampleID), path("*.trim.fq.gz"), val(condition), emit: reads
  path "*.fastp.json",                                       emit: json
  path "*.fastp.html",                                       emit: html

  script:
  """
  fastp \\
    --in1 $read1 --in2 $read2 \\
    --out1 ${sampleID}_1.trim.fq.gz --out2 ${sampleID}_2.trim.fq.gz \\
    --detect_adapter_for_pe \\
    --json ${sampleID}.fastp.json \\
    --html ${sampleID}.fastp.html \\
    --thread $task.cpus
  """

  stub:
  """
  touch ${sampleID}_1.trim.fq.gz ${sampleID}_2.trim.fq.gz
  echo fastp \\
    --in1 $read1 --in2 $read2 \\
    --out1 ${sampleID}_1.trim.fq.gz --out2 ${sampleID}_2.trim.fq.gz \\
    --detect_adapter_for_pe \\
    --json ${sampleID}.fastp.json \\
    --html ${sampleID}.fastp.html \\
    --thread $task.cpus > ${sampleID}.fastp.json
  touch ${sampleID}.fastp.html
  """
}