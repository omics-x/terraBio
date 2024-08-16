version 1.0
workflow ImputationQC {
    input {
        File infofile 
    }
call plotingResults {
          input:
            info_file = infofile,
        }
        output {
        File outputResult = plotingResults.outputpdf
        File outputResult2=plotingResults.outputpdf2
        }
}
task plotingResults{
    input {
        File info_file
    }
    command <<<
   set -euo pipefail
   R --no-save --args ~{info_file} <<RSCRIPT
      library('tidyverse')
      args <- commandArgs(trailingOnly = TRUE)
      df<-read.table(args[1],head=T)
      df <- df %>%
      mutate(MAF_Range = cut(MAF, breaks = c(0.001, 0.01, 0.05, 0.1, 0.5)))
      # Create a barplot
      pdf('Imputation_RSqplot.pdf')
      df %>%
      group_by(MAF_Range) %>%summarise(median_Rsq = median(Rsq)) %>%
      filter(!is.na(MAF_Range)) %>% 
      ggplot(aes(x = MAF_Range, y = median_Rsq, fill = MAF_Range)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Median Rsq values for different variants",x = "Minor Allele Frequency Range", y = "Median Rsq") +
      theme_minimal()
      dev.off()
      pdf('Imputation_RsqBox.pdf')
      df %>%
      group_by(MAF_Range) %>%
      filter(!is.na(MAF_Range)) %>% 
      ggplot(aes(x = MAF_Range, y = Rsq, fill = MAF_Range)) +
      geom_boxplot() +
      labs(title = "Rsq values for different variants", x = "Minor Allele Frequency Range", y = "Imputation Quality (Rsq)") + theme_minimal() + 
      theme(panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      axis.line = element_line(color = "black"))
      dev.off()
   RSCRIPT
    >>>
    output {
        File outputpdf = "Imputation_RSqplot.pdf"
        File outputpdf2 = "Imputation_RsqBox.pdf"
    }
    runtime{
        docker: "rocker/tidyverse"
	    memory: "120G"
        disks: "local-disk 50 HDD"
    }
}
