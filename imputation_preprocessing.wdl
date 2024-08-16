version 1.0
workflow plink_tasks {
    input {
        File bedFile
        File bimFile
        File famFile
    }
call plink_freq {
          input:
            bed_file = bedFile,
            bim_file = bimFile,
            fam_file = famFile,
            output_name = "ADNIfreq"
        }
call HRCmaincheck {
          input:
            bed_file = bedFile,
            bim_file = bimFile,
            fam_file = famFile,
            freq_file = plink_freq.output_file,
        }
    output {
        File OutputFile = plink_freq.output_file
        Array[File] FinalVCF = HRCmaincheck.output_vcf
    }
}

task  plink_freq {
    input {
        File bed_file
        File bim_file
        File fam_file
        String output_name
    }

    command <<<
        set -euo pipefail

        plink \
        --bed ~{bed_file} \
        --bim ~{bim_file} \
        --fam ~{fam_file} \
        --chr 20-22 \
        --freq  \
        --out ~{output_name} \
    >>>

    output {
        File output_file = output_name +".frq"
    }

    runtime {
        docker: "ghcr.io/omics-x/hrcimpcheck:v1"
        memory: "60G"
        disks: "local-disk 60 HDD"
    }
}

task  HRCmaincheck {
    input {
        File bim_file
        File bed_file
        File fam_file
        File freq_file
    }

    command <<<
        set -euo pipefail
        perl /tools/HRC-1000G-check-bim-v4.2.pl \
        -b ~{bim_file} \
        -f ~{freq_file} \
        -r /tools/HRC.r1-1.GRCh37.wgs.mac5.sites.tab \
        -h HRC
        ln -s ~{bed_file} ADNI_cluster_01_forward_757LONI.bed
        ln -s ~{bim_file} ADNI_cluster_01_forward_757LONI.bim
        ln -s ~{fam_file} ADNI_cluster_01_forward_757LONI.fam
        bash ./Run-plink.sh
        for i in {1..22}; do
            plink --bfile ADNI_cluster_01_forward_757LONI-updated-chr${i} --recode vcf --out ADNI_cluster_01_forward_757LONI-updated-chr${i};
        done
        for i in {1..22};do
        bcftools sort ADNI_cluster_01_forward_757LONI-updated-chr${i}.vcf -Oz -o ADNI_cluster_01_forward_757LONI-updated-chr${i}.vcf.gz; 
        done
    >>>

    output {
        Array[File] output_vcf = glob("*.vcf.gz")
    }
    runtime {
        docker: "ghcr.io/omics-x/hrcimpcheck:v1"
        memory: "60G"
        disks: "local-disk 40 HDD"
    }
}
