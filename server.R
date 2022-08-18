library(shiny)
library(shinyjs)
library(ggplot2)
library(shinycssloaders)
library(readr)
shinyServer(function(input, output) {
 
descriptiondataset <-read_csv("data/datadescription.csv")


      
 output$a <- DT::renderDataTable(descriptiondataset, filter = 'top', options = list(
        pageLength = 100, autoWidth = TRUE))
  
  data <- read_csv("data/merged1.csv")
  LOCUS_ID <- sort(unique(data$LOCUS_ID))
  
# Filter data based on selections

  #Unique LOCUS_ID dropdown
  # Filter data based on selections
  output$results <- DT::renderDataTable({
    filtered <- 
      data %>%
      filter(LOCUS_ID == input$LOCUS_ID)
    filtered
  }, filter ='top',
  options = list( autoWidth = TRUE,dom = 'Bftsp',
                  pageLength = 50, columnDefs = 
                   list(list(className = 'dt-center', 
                             targets = "_all"))), callback = JS("
var tips = ['Chromosome', 'Position', 'Reference allele (col-0)',
          'Alternative allele', 'Minor allele frequency', 'Minor allele count', 
          'score (-log(p-value)) using a mixed model approach correcting for population structure. The higher the value is, the stronger the association is between genetic and environmental variation.',
          'score (-log(p-value)) using a linear model approach not correcting for population structure. The higher the value is, the stronger the association is between genetic and environmental variation.', 
          'q-values using a mixed model approach correcting for population structure.' ,
          'q-values using a linear model approach not correcting for population structure', 'Estimate local False Discovery Rate (FDR) using a mixed model approach correcting for population structure',
          'Estimate local False Discovery Rate (FDR) using a linear model approach not correcting for population structure',
          'Spearman’s rank correlation coeﬃcients between individual climate varriables and individual transcript abundance values. The stronger the association between climate and transcript variation, the closer the Pearson correlation coeﬃcient, rs, will be to either + 1 or − 1',
          'Correlation coefficient obtained using the SNPfold program. The closer this correlation coefficient is to 1, the less likely it is that the RNA structure is changed by the SNP. See text on the sidebar for a more detailed explanation.',
          'The fixation index (FST) is a measure of population differentiation due to genetic structure.',
          'Tajima D compares an observed nucleotide diversity against the expected diversity under the assumption that all polymorphisms are selectively neutral and constant population size.',
          'Nucleotide diversity (PI) calculated using a sliding window of 1 kb is the average pairwise difference between all possible pairs of individuals in the population',
          'Each locus in Arabidopsis is assigned a unique ID, termed the AGI locus code (AGI, Arabidopsis Genome Initiative). This ID consists of the prefix AT, followed by the chromosome identifier, a G (gene), and then a unique 5 digit number',
          'Current symbol for the gene locus (following (TAIR10.52)','Current annotation for the gene locus (following (TAIR10.52)','SNP effect prediction according to SnpEff using the latest TAIR10.52 release. See http://snpeff.sourceforge.net/VCFannotationformat_v1.0.pdf for definitions',
          'Source from which the environmental associated with the SNP was obtained from. See the tab with the description of climate variables for more information' ,'Description of the environmental associated with the SNP was obtained from. See the tab with the description of climate variables for more information'
          ],
    header = table.columns().header();
for (var i = 0; i < tips.length; i++) {
  $(header[i]).attr('title', tips[i]);
}
"),
  rownames= FALSE)})
  