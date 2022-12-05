// Modules
include { fastp }                                                          from './modules/fastp.nf'
include { star_index; star_align }                                         from './modules/star.nf'
include { samtools_sort }                                                  from './modules/samtools.nf'
include { rmats_run; rmats_parse_coords; rmats_filter }                    from './modules/rmats.nf'
include { whippet_index; whippet_quant; whippet_delta; whippet_filter }    from './modules/whippet.nf'
include { overlap; overlap_filter }                                        from './modules/rmappet.nf'

// Functions
def combinations(channel) {
	channel
		.groupTuple(by: 0)
		.toList()
		.map {
			[it, it]
			.combinations()
			.findAll{ a, b -> a[0] < b[0] }
		}
		.flatMap()
		.map {
			it -> [
				[ a: it[0][0], b: it[1][0] ],
				it[0][1],
				it[1][1]
			]
		}
}

// Channels
Channel.fromPath( params.samplesheet )
	.set { samplesheet_ch }
Channel.fromPath( params.genome )
	.set{ genome_ch }
Channel.fromPath( params.annotation )
	.set{ annotation_ch }

if ( params.libtype == "single" ) {	
	samplesheet_ch.splitCsv( header: true )
		.take( params.dev ? 1: -1 )
		.map{ row -> [
				row.sample_id, file( row.read1 ), row.condition
		]}
		.set { read_ch }
} else if ( params.libtype == "paired" ) {
	samplesheet_ch.splitCsv( header: true )
		.take( params.dev ? 1: -1 )
		.map{ row -> [
				row.sample_id, [ file( row.read1 ), file( row.read2 ) ], row.condition
		]}
		.set { read_ch }
}

// Workflow
workflow {
  fastp( read_ch )
  star_index( genome_ch, annotation_ch )
  star_align( star_index.out.index.collect(), fastp.out.reads )
  samtools_sort( star_align.out.bam )
  samtools_sort.out.bam
    .map { it -> [ it[2], it[1][0], it[0] ] }
    .set { rmats_ch }

  // rMATS
  rmats_run( combinations( rmats_ch ), annotation_ch.collect() )
  rmats_parse_coords( rmats_run.out.data )
	rmats_filter( rmats_parse_coords.out.data )

  // Whippet
  whippet_index( genome_ch, annotation_ch )
  whippet_quant( whippet_index.out.index.collect(), fastp.out.reads )
  whippet_quant.out.psi
    .map { it -> [ it[2], it[1], it[0] ] }
    .set { whippet_ch }
  whippet_delta( combinations( whippet_ch ) )
	whippet_filter( whippet_delta.out.delta )

	// Overlap
	rmats_parse_coords.out.data
		.map { it -> [ it[0], it[1] ] }
		.join( whippet_delta.out.delta, by: 0 )
		.set { overlap_ch }
	
	overlap( overlap_ch )
	overlap_filter( overlap.out.data )
}