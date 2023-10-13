library('ggplot2')
library('ggsignif')

df<-read.csv('data/Study_Info/ADNIMERGE_19May2023.csv')
grn<-read.csv('data/Biospecimen/ADNI_HAASS_WASHU_LAB_20May2023.csv')
cdr<-read.csv('data/Assessments/CDR_19May2023.csv')

#### In the GRN/cdr file viscode2 corresponds to viscode in the merged file 
df$RID_VISCODE<-paste0(df$RID,'_',df$VISCODE)
grn$RID_VISCODE<-paste0(grn$RID,'_',grn$VISCODE2)


merged<-merge(grn,df,by='RID_VISCODE',all.x = T)
 
# Only filtering the baseline, m12 and m24
dfgrn<-merged[which(merged$VISCODE2%in%c('bl')),]
# Log transform and scale the progranulin variable
dfgrn$log_scaled_msd_pgrn_correct<-scale(log(dfgrn$MSD_PGRNCORRECTED), center = T,scale = T)
dfgrn<-dfgrn[which(!is.na(dfgrn$log_scaled_msd_pgrn_correct)),]


dfgrn$CDR_categories<-NA
dfgrn$CDR_categories[which(dfgrn$CDRSB_bl==0)]<-0
dfgrn$CDR_categories[which(dfgrn$CDRSB_bl>=0.5 & dfgrn$CDRSB_bl<=4)]<-0.5
dfgrn$CDR_categories[which(dfgrn$CDRSB_bl>=4.5)]<-1

# Plot the relationship between GRN and CSF markers 
pdf('PGRN_comparison_between_CDR_scores.pdf')
ggplot(dfgrn,aes(x=as.factor(CDR_categories),y=log_scaled_msd_pgrn_correct)) + 
  geom_boxplot() + xlab('Alzheimers disease continum (CDR score)') + ylab('CSF progranulin levels') + 
  geom_signif(comparisons = list(c("0", "0.5"), c("0", "1"), c("0.5", "1")),
              test = "t.test", y_position = c(3,4,5)) 
dev.off()

pdf('PGRN_comparison_AD_diagnosis.pdf')
ggplot(dfgrn,aes(x=factor(DX_bl,levels = c('CN', 'SMC', 'EMCI', 'LMCI', 'AD')), 
                 y=log_scaled_msd_pgrn_correct)) + geom_boxplot(width=0.3) +
  xlab('Dementia diagnosis') + ylab('CSF progranulin levels')+
  geom_signif(comparisons = list(c('CN','SMC'), c('CN','EMCI'), c('CN','LMCI'), c('CN','AD')), test='t.test', y_position =c(2.5, 3, 3.5, 4))
dev.off()

