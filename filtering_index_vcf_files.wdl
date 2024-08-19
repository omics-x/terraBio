version 1.0
task indexfilterconversion {
    input {
        File inputvcf_file
        Float MAF_threshold_argument
        Float imp_info_argument
    }

    command <<<
        set -euo pipefail
        bcftools index ~{inputvcf_file}


        tempvcf=~{inputvcf_file}
        filename=$(basename "$tempvcf")
        name_prefix="${filename%.dose.vcf}"
        bcftools view -i 'R2>~{imp_info_argument} & MAF[0]>~{MAF_threshold_argument}' ~{inputvcf_file} | bgzip > ${name_prefix}.MAF_Rsq_filtered.vcf.gz
        bcftools index ${name_prefix}.MAF_Rsq_filtered.vcf.gz
        /tools/qctool -g ${name_prefix}.MAF_Rsq_filtered.vcf.gz -vcf-genotype-field GP -og ${name_prefix}_R2gt0.3_AND_MAFgt0.001.bgen
    >>>

    output {
        Array[File] filtered_bgenfiles = glob("*_R2gt0.3_AND_MAFgt0.001.bgen")
    }

    runtime {
        docker: "ghcr.io/omics-x/bcfnqctools:v1"
        memory: "60G"
        disks: "local-disk 60 HDD"
    }
}

workflow preprocessImputedVCF{
    input {
        Array[File] vcfFiles
        Float MAF_threshold
        Float imp_info
    }
    scatter(vcf in vcfFiles){

        call indexfilterconversion {
            input:
                inputvcf_file = vcf,
                MAF_threshold_argument = MAF_threshold,
                imp_info_argument = imp_info
            }
        }
         Array[File] bgenfiles = flatten(indexfilterconversion.filtered_bgenfiles)
         output{
            Array[File] filteredbgenfiles = bgenfiles
         }
    }
   