
library(ggplot2)
library(shiny)
library(plotly)
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
  tags$head(
    includeHTML("google-analytics.html"),
    tags$link(rel="stylesheet", type="text/css", href="style.css"),
    tags$script('!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?"http":"https";if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document, "script", "twitter-wjs");'),
    
    # Custom CSS for DataTable horizontal scroll bar and additional styles
    tags$style(HTML("
    /* Ensures that the DataTables fill their container */
    .container-fluid .row, .container-fluid {
      padding: 0 !important;
      margin: 0 !important;
    }
    
    /* Ensures that the DataTables themselves are full width */
    .dataTables_wrapper {
      overflow-x: auto !important; /* Enable horizontal scrolling */
      width: calc(115% - 30px) !important; /* Adjust width, assuming 15px padding on each side of the container */
      box-sizing: border-box; /* Includes padding in the element's total width */
    }
    .dataTables_scrollHeadInner, .dataTables_scrollBody {
      width: 100% !important; /* Forces the inner scroll area to be full width */
    }
    .dataTables_scrollHeadInner table, .dataTables_scrollBody table {
      width: 100% !important; /* Forces the tables within the DataTable to be full width */
      margin: 0; /* Remove automatic margin */
    }
    
    /* Custom scrollbar styling */
    ::-webkit-scrollbar {
      height: 12px;
      width: 12px;
    }
    ::-webkit-scrollbar-thumb {
      background-color: black;
    }
    
    /* Adjust scrollbar for DataTable head and body */
    .dataTables_scrollHead::-webkit-scrollbar,
    .dataTables_scrollBody::-webkit-scrollbar {
      height: 12px;
    }
    .dataTables_scrollHead::-webkit-scrollbar-thumb,
    .dataTables_scrollBody::-webkit-scrollbar-thumb {
      background-color: black;
    }
    
    /* Table styling */
    .dataTables_wrapper {
      font-family: 'Arial', sans-serif;
    }
    .dataTables_wrapper table {
      border-collapse: collapse;
    }
    .dataTables_wrapper thead th {
      background-color: #4CC9F0;
      color: #fff;
      font-weight: bold;
    }
    .dataTables_wrapper tbody td {
      padding: 8px;
      text-align: center;
    }
    .dataTables_wrapper tbody tr:nth-child(even) {
      background-color: #f2f2f2;
    }
    .dataTables_wrapper tbody tr:hover {
      background-color: #4CC9F0;
    }
  "))
  ),
  
  useShinyjs(),
  
  uiOutput("app"),
  headerPanel(
    list(
      tags$head(
        tags$style(
          "body {background-color: white;}",
          ".app-header {background-color: #4CC9F0; padding: 50px;}",
          ".app-title {color: white; font-size: 80px; margin-bottom: 10px;}",
          ".app-subtitle {color: #2c3e50; font-size: 30px;}"
        )
      ),
      HTML(
        '<div class="app-header">
        <img src="picture2.png" height="225px" style="float:left; margin-left: -50px; margin-top: -40px;"/>
        <div style="display: flex; flex-direction: column; margin-left: 10px;">
          <p class="app-title">GenoCLIM v2.0</p>
          <p class="app-subtitle">Find Your Gene’s Environmental Association</p>
        </div>
      </div>'
      )
    )
  ),
  theme = shinytheme("journal") , 
  
  tabsetPanel(              
    tabPanel(type = "pills", title = "Find your gene",(sidebarPanel(
      wellPanel(
        a(
          HTML("<p style='text-align: center; font-size: 15px; color: black;'>Type your locus/loci of interest in the search box to explore the association between its genetic variation with any geoclimatic variable (i.e. AT5G35840). The GxE information for your gene of interest will be displayed in the data table and the reactive plot underneath.</p>"),
          textInput("LOCUS_ID", label = NULL, width = "100%", placeholder = "Enter Locus ID (AGI)")
        ),
        style = "background: #4CC9F0"
      ), 
      wellPanel(a(div(id = "snpfold_info", style = "display: none;",
                      h4("SNPfold Correlation Coefficient (SNPfold CC)"),
                      h6(style = "text-align: justify;",
                         "The SNPfold algorithm (Halvorsen et al., 2010) considers the ensemble of structures predicted by the RNA partition functions of RNAfold (Bindewald & Shapiro, 2006) for each reference and alternative sequence and quantifies structural differences between these ensembles by calculating a Pearson correlation coefficient on the base-pairing probabilities between the two sequences. The closer this correlation coefficient is to 1, the less likely it is that the RNA structure is changed by the SNP. The creators of SNPfold note (Corley et al., 2015) that for genome-wide prediction, the bottom 5% of the correlation coefficient values (corresponding in this CLIMtools dataset to a correlation coefficient of 0.445) are most likely to be riboSNitches and the top 5% of correlation coefficient values (corresponding in this CLIMtools dataset to a correlation coefficient of 0.99) are most likely to be non-riboSNitches. Correlation coefficients are provided for all SNPs within protein-coding genes, unless the SNP was located < 40 nt from a transcript end, in which case the correlation coefficient is indicated as “not calculated.” The correlation coefficient for SNPs within upstream regions are indicated as “non applicable.”"),
                      h6("-Halvorsen M, Martin JS, Broadaway S, Laederach A. Disease‐associated mutations that alter the RNA structural ensemble. PLoS Genet. 2010;6:e1001074."),
                      h6("-Bindewald, E, & Shapiro, BA. RNA secondary structure prediction from sequence alignments using a network of k-nearest neighbor classifiers. Rna. 2006;12:342-352.")
      ),
      
      # Add a button to toggle the visibility of the div
      
      actionButton("toggle_snpfold_info", 
                   label = HTML("<p style='color:white; font-size:16px; display: inline-block; white-space: normal; overflow: hidden; text-overflow: clip; max-width: 100%;'>What is the SNPfold Correlation Coefficient?</p>"), 
                   style = "background-color: #3498db; width:100%; padding: 10px")
      ,
      
      
      # Use JavaScript/jQuery to toggle the visibility of the div when the button is clicked
      tags$script(
        "$(document).on('click', '#toggle_snpfold_info', function() {
     $('#snpfold_info').toggle();
   });"
      ))
      ),
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
        
        fixedRow(column(12,h4("Mouse-over column names and wait for the pop-up for a more detailed description of variables"),
                        dataTableOutput("results"), plotlyOutput("scatter_plot", width = '115%',)
        ))
        
        
                  

  
  )), 
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