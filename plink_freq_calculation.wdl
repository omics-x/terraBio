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
            output_name = "TutotialFile"
        }
call processing {
        input:
        freqFile = plink_freq.output_file
		}

    output {
        File OutputFile = plink_freq.output_file
        File OutputFile2 = processing.output2
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

        /tools/plink2 \
        --bed ~{bed_file} \
        --bim ~{bim_file} \
        --fam ~{fam_file} \
        --freq  \
        --out ~{output_name} \
    >>>

    output {
        File output_file = "${output_name}.afreq"
    }

    runtime {
        docker: "ghcr.io/omics-x/plinkdoc_alpine:v3"
	    memory: "4G"
        disks: "local-disk 16 HDD"
    }
}

task processing {
    input {
        File freqFile
    }
    command <<<
        set -euo pipefail

        R --no-save --args ~{freqFile} <<RSCRIPT
        library('tidyverse')
        args <- commandArgs(trailingOnly = TRUE)
        a<-read.table(args[1],head=F)
        variantFreq<- a %>% select(V1:V3, V6) %>% 
        mutate(name = paste0(V1, ':', V2)) %>% 
        rename(Freq = V6) %>% select (name, Freq)
        write.csv(variantFreq,file='variantFreq.csv')
        RSCRIPT
    >>>

    output {
        File output2 = "variantFreq.csv"
    }
    runtime{
        docker: "rocker/tidyverse"
	    memory: "4G"
        disks: "local-disk 16 HDD"
    }
}
