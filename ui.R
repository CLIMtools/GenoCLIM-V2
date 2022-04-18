
library(ggplot2)
library(shiny)
library(shinythemes)
library(DT)
library(shinycssloaders)
library(shinyjqui)
library(shinyjs)
library(markdown)
library(spsComps)
library(dplyr, warn.conflicts = FALSE)
library(shinyWidgets)
library(readr)
data <- read_csv("data/merged1.csv")
LOCUS_ID <- sort(unique(data$LOCUS_ID))

shinyUI(fluidPage(
  # Add Javascript
  tags$head(
    tags$link(rel="stylesheet", type="text/css",href="style.css"),
    tags$head(includeScript("google-analytics.js")),
    tags$script(type="text/javascript", src = "md5.js"),
    tags$script(type="text/javascript", src = "passwdInputBinding.js"),
    tags$script('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)    [0],p=/^http:/.test(d.location)?\'http\':\'https\';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");')
    
  ),
  useShinyjs(),
  
  uiOutput("app"),
  headerPanel(
    list(tags$head(tags$style("body {background-color: white; }")),
         "                     GenoCLIM V2.0", HTML('<img src="picture2.png", height="100px",  
                           style="float:left"/>','<p style="color:blue">                    Find Your Gene’s Environmental Association </p>' ))
  ),
  
  theme = shinytheme("journal") , 
  
  tabsetPanel(              
    tabPanel(type = "pills", title = "Find your gene",(sidebarPanel(
      wellPanel(pickerInput("LOCUS_ID", "Type your locus/loci of interest using the AGI locus code in the search box to explore the association between its genetic variation with any geoclimatic variable (i.e. AT5G35840)", choices = LOCUS_ID, selected = "AT5G35840",  options = list(`actions-box` = TRUE, `live-search` = TRUE), multiple = TRUE),style = "background: #c0e6ea" ),
      wellPanel(a(h4('SNPfold Correlation Coefficient (SNPfold CC)'),  h6(style="text-align: justify;",'The SNPfold algorithm (Halvorsen et al., 2010) considers the ensemble of structures predicted by the RNA partition functions of RNAfold (Bindewald & Shapiro, 2006) for each reference and alternative sequence and quantifies structural differences between these ensembles by calculating a Pearson correlation coefficient on the base-pairing probabilities between the two sequences. The closer this correlation coefficient is to 1, the less likely it is that the RNA structure is changed by the SNP. The creators of SNPfold note (Corley et al., 2015) that for genome-wide prediction, the bottom 5% of the correlation coefficient values (corresponding in this CLIMtools dataset to a correlation coefficient of 0.445) are most likely to be riboSNitches and the top 5% of correlation coefficient values (corresponding in this CLIMtools dataset to a correlation coefficient of 0.99) are most likely to be non-riboSNitches.'), 
                  h6('-Halvorsen M, Martin JS, Broadaway S, Laederach A. Disease‐associated mutations that alter the RNA structural ensemble. PLoS Genet. 2010;6:e1001074.'),
                  h6('-Bindewald, E, & Shapiro, BA. RNA secondary structure prediction from sequence alignments using a network of k-nearest neighbor classifiers. Rna. 2006;12:342-352.'))),
                  wellPanel(a(h4('Please cite us in any publication that utilizes information from Arabidopsis CLIMtools:'),  
                  h6('-Ferrero‑Serrano, Á, Sylvia, MM, Forstmeier, PC, Olson, AJ, Ware, D,Bevilacqua, PC & Assmann, SM. Experimental demonstration and pan‑structurome prediction of climate‑associated riboSNitches in Arabidopsis. Genome Biology. DOI: 10.1186/s13059‐022‐02656‐4.' ), h6('-Ferrero-Serrano, Á & Assmann SM. Phenotypic and genome-wide association with the local environment of Arabidopsis. Nature Ecology & Evolution. DOI: 10.1038/s41559-018-0754-5 (2019)' ))),
   
  #    wellPanel(
  #      uiOutput("datasets")
  #    ),
  #uiOutput("ui_Manage")
      uiOutput("ui_All"),
      width=3, wellPanel(tags$a(img(src='genoclimwarning.png', h3("Considerations before using this tool"), height="120px"),href="myfile.pdf"),align="center"), wellPanel(tags$a(img(src='FDR.png', h3("Explore FDR of any ExG association"), height="120px"),href="myfile.pdf"),align="center"), wellPanel(a("Tweets by @ClimTools", class="twitter-timeline"
                                                                                                                                                                                                                                                                                                              , href = "https://twitter.com/ClimTools"), style = "overflow-y:scroll; max-height: 1000px"
      ),
      wellPanel( h6('Contact us: clim.tools.lab@gmail.com')), wellPanel(tags$a(div(
        img(src = 'github.png',  align = "middle"), style = "text-align: center;"
      ), href = "https://github.com/CLIMtools/GenoCLIM"))
    )
      
  ###################################################
  ###################################################
    ),
    
  ###################################################
  mainPanel(  
  ###add code to get rid of error messages on the app.   
        tags$style(type="text/css",
                   ".shiny-output-error { visibility: hidden; }",
                   ".shiny-output-error:before { visibility: hidden; }"
        ),
             
  # Create a new row for the table.
  
  fixedRow(column(6,h4("Mouse-over column names and wait for the pop-up for a more detailed description of variables"),
    withSpinner(DT::dataTableOutput("results"))
    
  )))), 
  tabPanel(title = "Description of climate variables",  mainPanel(fixedRow(
    width = 12,
    withSpinner(DT::dataTableOutput("a"))
  ))),
  
  tabPanel(title = "About",  mainPanel(h1(div('About GenoCLIM V2.0', style = "color:blue")), 
                                       h3(div('GenoCLIM V2.0 is an SHINY component of CLIMtools V2.0, that provides an intuitive tool to explore the environmental variation associated to any gene or variant of interest in Arabidopis.', style = "color:grey")),
                                       h3(div('GenoCLIM allows the user to input the locus ID, genetic position or keyword within a particular locus description to explore its association with any oif the multiple environmental variables available from CLIMtools ', style = "color:grey")),
                                       h3(div('Code and data for CLIMtools V2.0 have been uploaded to Dryad and Zenodo https://datadryad.org/stash/dataset/doi:10.5061/dryad.mw6m905zj  ', style = "color:grey")),
                                       
                                       h3(''),
                                       h3(''),
                                       tags$a(div(img(src='climtools.png',  align="middle"), style="text-align: center;"), href="http://www.personal.psu.edu/sma3/CLIMtools.html"),
                                       tags$a(div(img(src='climtools logo.png',  align="middle"), style="text-align: center;"), href="http://www.personal.psu.edu/sma3/CLIMtools.html"),
                                       tags$a(div(img(src='Gramene.jpg',  align="middle"), style="text-align: center;"), href="https://www.gramene.org/"),
                                       
                                       
                                       h3(''),
  )))
))