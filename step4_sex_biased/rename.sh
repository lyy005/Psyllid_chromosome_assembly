for i in aphid_sex.DESeq2_normalized.table aphid_sex_female.DESeq2_pvalue.table aphid_sex_male.DESeq2_pvalue.table aphid_sex_asexual.DESeq2_pvalue.table
 do
  perl replace_one_geneID_DESeq2.pl $i GCF_005508785.1_mt_combined.gff $i\.rename
 done

# psyllid
#perl replace_one_geneID_DESeq2.psyllid.pl psyllid_sex.DESeq2_normalized.table psyllid_sex.DESeq2_normalized.table.rename 
#perl replace_one_geneID_DESeq2.psyllid.pl psyllid_sex.DESeq2_pvalue.table psyllid_sex.DESeq2_pvalue.table.rename
#perl replace_one_geneID_DESeq2.psyllid.pl psyllid_symbiont.DESeq2_normalized.table psyllid_symbiont.DESeq2_normalized.table.rename
#perl replace_one_geneID_DESeq2.psyllid.pl psyllid_symbiosis.DESeq2_pvalue.table psyllid_symbiosis.DESeq2_pvalue.table.rename
