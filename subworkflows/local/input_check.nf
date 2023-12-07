//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_bam_channel(it) }
        .set { bam_files }

    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

    emit:
    bam_files = bam_files                 // channel: [ val(meta), [ bams ] ]
    versions = ch_versions               // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ tumorBam, normalBam, assay, normalType ] ]
def create_bam_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.pairId
    meta.assay      = row.assay
    meta.normalType = row.normalType

    // add path(s) of the bam files to the meta map
    def bams = []
    def bedFile = null
    if (!file(row.tumorBam).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Tumor BAM file does not exist!\n${row.tumorBam}"
    }
    if (!file(row.normalBam).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Normal BAM file does not exist!\n${row.normalBam}"
    }

    def tumorBai = "${row.tumorBam}.bai"
    def normalBai = "${row.normalBam}.bai"
    def tumorBaiAlt = "${row.tumorBam}".replaceAll('bam$', 'bai')
    def normalBaiAlt = "${row.normalBam}".replaceAll('bam$', 'bai')

    def foundTumorBai = ""
    def foundNormalBai = ""


    if (file(tumorBai).exists()) {
        foundTumorBai = tumorBai
    }
    else{
        if(file(tumorBaiAlt).exists()){
            foundTumorBai = tumorBaiAlt
        }
        else{
        exit 1, "ERROR: Please verify inputs -> Tumor BAI file does not exist!\n${row.tumorBam}"
        }
    }
    if (file(normalBai).exists()) {
        foundNormalBai = normalBai
    }
    else{
        if(file(normalBaiAlt).exists()){
            foundNormalBai = normalBaiAlt
        }
        else{
            exit 1, "ERROR: Please verify inputs -> Normal BAI file does not exist!\n${row.normalBam}"
        }
    }


    bams = [ meta, [ file(row.tumorBam), file(row.normalBam) ], [ file(foundTumorBai), file(foundNormalBai) ]]
    return bams
}
