include { SNPPILEUP } from '../../modules/local/snppileup'
include { FACETS } from '../../modules/local/facets'

workflow CNV {

    take:
    ch_bams                                               // channel: //  [ meta (id, assay, normalType), [ tumorBam, normalBam ], [ tumorBai, normalBai ]]

    main:

    ch_versions = Channel.empty()

    SNPPILEUP(
        ch_bams
    )
    ch_versions = ch_versions.mix(SNPPILEUP.out.versions)

    FACETS(
        SNPPILEUP.out.pileup
    )
    ch_versions = ch_versions.mix(FACETS.out.versions)


    emit:
    pileup      = SNPPILEUP.out.pileup                    // channel: [ val(meta), [ pileup ] ]
    purity_seg = FACETS.out.purity_seg                    // channel: [ val(meta), [ purity_seg ]]
    purity_rdata = FACETS.out.purity_rdata                // channel: [ val(meta), [ purity_rdata ]]
    purity_png = FACETS.out.purity_png                    // channel: [ val(meta), [ purity_png ]]
    purity_out = FACETS.out.purity_out                    // channel: [ val(meta), [ purity_out ]]
    purity_cncf_txt = FACETS.out.purity_cncf_txt          // channel: [ val(meta), [ purity_cncf_txt ]]
    hisens_seg = FACETS.out.hisens_seg                    // channel: [ val(meta), [ hisens_seg ]]
    hisens_rdata = FACETS.out.hisens_rdata                // channel: [ val(meta), [ hisens_rdata ]]
    hisens_png = FACETS.out.hisens_png                    // channel: [ val(meta), [ hisens_png ]]
    hisens_out = FACETS.out.hisens_out                    // channel: [ val(meta), [ hisens_out ]]
    hisens_cncf_txt = FACETS.out.hisens_cncf_txt          // channel: [ val(meta), [ hisens_cncf_txt ]]
    qc_txt = FACETS.out.qc_txt                            // channel: [ val(meta), [ qc_txt ]]
    gene_level_txt = FACETS.out.gene_level_txt            // channel: [ val(meta), [ gene_level_txt ]]
    arm_level_txt = FACETS.out.arm_level_txt              // channel: [ val(meta), [ arm_level_txt ]]
    output_txt = FACETS.out.output_txt                    // channel: [ val(meta), [ output_txt ]]
    versions = ch_versions                                // channel: [ versions.yml ]
}

