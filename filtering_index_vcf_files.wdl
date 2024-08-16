version 1.0
task indexingvcf {
    input {
        Array[File] vcfFileforindex
    }

    command <<<
            bcftools index vcfFileforindex
    >>>

    output {
        Array[File] indexedvcf = glob(*vcfFileforindex*)
    }

    runtime {
        docker: "?"
        memory: "60G"
        disks: "local-disk 60 HDD"
    }
}

task  filteringvcf {
    input {
        Array[File] indexedvcfforfiltering
        Float MAF_threshold_forfiltering
        Float imputation_Info_forfiltering
    }

    command <<<
        set -euo pipefail
        for i in 1...2;do
        bcftools view -i 'R2>~{MAF_threshold_forfiltering} & MAF[0]>~{imputation_Info_forfiltering}' ~{indexedvcfforfiltering} | bgzip > chr{i}.MAF_Rsq_filtered.vcf.gz
        bcftools index chr{i}.MAF_Rsq_filtered.vcf.gz
        done
    >>>

    output {
        Array[File] filtered_vcf_files = glob("*MAF_Rsq_filtered.vcf.gz")
    }
    runtime {
        docker: " "
        memory: "60G"
        disks: "local-disk 40 HDD"
    }
}

task  conversiontobgen {
    input {
        Array[File] vcfforconverion

    }

    command <<<
        CHR=`echo $file | cut -d '/' -f6 | cut -d '.' -f1`
        /qctool_v2.2.0-CentOS\ Linux7.8.2003-x86_64/./qctool -g $file -vcf-genotype-field GP -og ${CHR}.dose.filtered_vcf_R2gt0.3_AND_MAFgt0.001.bgen
    done

    >>>
    output {
        Array[File] output_vcf2 = glob("*MAF_Rsq_filtered.vcf.gz")
    }
    runtime {
        docker: ""
        memory: "60G"
        disks: "local-disk 40 HDD"
    }
}


workflow preprocessImputedVCF{
    input {
        Array[File] vcfFile
        Float MAF_threshold
        Float imputation_Info
    }
call indexingvcf {
          input:
            vcfFileforindex = vcfFile,
        }
call filteringvcf {
          input:
            indexedvcfforfiltering = indexingvcf.indexedvcf,
            MAF_threshold_forfiltering = MAF_threshold,
            imputation_Info_forfiltering = imputation_Info
        }
call conversiontobgen {
          input:
            vcfforconverion = filteringvcf.filtered_vcf_files
        }
    }
}