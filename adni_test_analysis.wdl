version 1.0

task basicADNI {
  input {
    File scriptFile
    File adnimerge
    File grn
    File cdr
  }

  command <<<
    Rscript ~{scriptFile} --adnimerge ~{adnimerge} --dfgrn ~{grn} --dfcdr ~{cdr} 
  >>>
  
 runtime {
            docker: "rocker/tidyverse"
	    memory: "4G"
            disks: "local-disk 16 HDD"

       }  
  output {
    File outputFile = "combined_grnfile.csv"
    File outputPdf1 = "PGRN_comparison_between_CDR_scores.pdf"
    File outputPdf2 = "PGRN_comparison_AD_diagnosis.pdf"
    
  }
}



workflow CallingScript {
  input {
    # File rScript1
    # File adnimerge1
    # File grn1
    # File cdr1

		File rScript1 = "/Users/shahzada/Documents/IMCM/terraBio/terraBio/adni_script_wdl.R"
		File adnimerge1 = "/Users/shahzada/Documents/IMCM/terraBio/ADNIMERGE_19May2023.csv"
		File grn1 = "/Users/shahzada/Documents/IMCM/terraBio/ADNI_HAASS_WASHU_LAB_20May2023.csv"
		File cdr1 = "/Users/shahzada/Documents/IMCM/terraBio/CDR_19May2023.csv"

  }
  call basicADNI {
    input:
      scriptFile = rScript1,
      adnimerge = adnimerge1,
      grn = grn1, 
      cdr = cdr1,
  }
  output {
    File outputResult1 = basicADNI.outputFile
    File outputResult2 = basicADNI.outputPdf1
    File outputResult3 = basicADNI.outputPdf2
  }
}