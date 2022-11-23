// Modules
include { fastp } from './modules/fastp.nf'

// Channels
Channel.fromPath( params.samplesheet )
	.set { samplesheet_ch }
Channel.fromPath( params.genome )
	.set{ genome_ch }
Channel.fromPath( params.annotation )
	.set{ annotation_ch }

samplesheet_ch.splitCsv( header: true )
	.take( params.dev ? 1: -1 )
	.map{ row -> [
			row.sample_id, file( row.read1 ), file( row.read2 ), row.condition
	]}
	.set { read_ch }

// Workflow
workflow {
  fastp( read_ch )
  // star_index()
  // star_align()
  // samtools_sort()
  // rmats_run()
  // whippet_index()
  // whippet_quent()
  // whippet_delta()
}