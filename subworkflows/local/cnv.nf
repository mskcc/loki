include { SNPPILEUP } from '../../modules/msk/snppileup/main'
include { FACETS } from '../../modules/msk/facets/main'

workflow CNV {

    take:
    ch_bams                                               // channel: //  [ meta (id, assay, normalType), [ tumorBam, normalBam ], [ tumorBai, normalBai ]]

    main:

    ch_versions = Channel.empty()
    ch_dbsnp = Channel.value([ "dbsnp", file(params.dbsnp), file(params.dbsnp_index) ])

    SNPPILEUP(
        ch_bams,
        ch_dbsnp
    )
    ch_versions = ch_versions.mix(SNPPILEUP.out.versions)

    ch_facets_input = SNPPILEUP.out.pileup.map {
        new Tuple(it[0],it[1],true)
    }

    FACETS(
        ch_facets_input
    )
    ch_versions = ch_versions.mix(FACETS.out.versions)


    emit:
    pileup      = SNPPILEUP.out.pileup                    // channel: [ val(meta), [ pileup ] ]
    purity_seg = FACETS.out.purity_seg                    // channel: [ val(meta), [ purity_seg ]]
    purity_rdata = FACETS.out.purity_r_data               // channel: [ val(meta), [ purity_r_data ]]
    purity_png = FACETS.out.purity_png                    // channel: [ val(meta), [ purity_png ]]
    purity_out = FACETS.out.purity_out                    // channel: [ val(meta), [ purity_out ]]
    purity_cncf_txt = FACETS.out.purity_cncf_txt          // channel: [ val(meta), [ purity_cncf_txt ]]
    hisens_seg = FACETS.out.hisens_seg                    // channel: [ val(meta), [ hisens_seg ]]
    hisens_rdata = FACETS.out.hisens_r_data               // channel: [ val(meta), [ hisens_r_data ]]
    hisens_png = FACETS.out.hisens_png                    // channel: [ val(meta), [ hisens_png ]]
    hisens_out = FACETS.out.hisens_out                    // channel: [ val(meta), [ hisens_out ]]
    hisens_cncf_txt = FACETS.out.hisens_cncf_txt          // channel: [ val(meta), [ hisens_cncf_txt ]]
    qc_txt = FACETS.out.qc_txt                            // channel: [ val(meta), [ qc_txt ]]
    gene_level_txt = FACETS.out.gene_level_txt            // channel: [ val(meta), [ gene_level_txt ]]
    arm_level_txt = FACETS.out.arm_level_txt              // channel: [ val(meta), [ arm_level_txt ]]
    output_txt = FACETS.out.output_txt                    // channel: [ val(meta), [ output_txt ]]
    versions = ch_versions                                // channel: [ versions.yml ]
}

