################################################################################
# UI of the app
#
# Author: GOMES Michel
# Created: 04-10-2022 
################################################################################



home_page <-bootstrapPage(htmlTemplate("www/index.html",
                                 # table = DT::dataTableOutput("table"),
                                 input1 = fileInput("file1", "faites glisser ou clickez ici"),
                                  
                                  nb_cell = textOutput("nb_cell"),
                                  nb_gene = textOutput("nb_gene"),
                                  nb_cellType = textOutput("nb_cellType"),
                                  source1 = uiOutput("source1"),
                                  button = uiOutput("button"),
                                  resview = uiOutput("resview"),

                                  res = textOutput("result"),
                                  res2 = textOutput("result2"),
                                  visual_circle_all = plotOutput("visual_circle_all"),

                                  # csstyle = tags$head(includeCSS("cran-explorer/app//style.css")),
                                  # csstyle2 = tags$head(includeCSS("cran-explorer/app//css/animate.css")),
                                  # # includeScript("www/js/scripts.js"),
    
 

  )
)
communactionCellCell <- (htmlTemplate("www/communactionCellCell.html",
                                  source1 = uiOutput("source1"),
                                  button = uiOutput("button"),
                                  res = textOutput("result"),
                                  res2 = textOutput("result2"),
                                  

                                  visual_circle = plotOutput("visual_circle"),
                                  visual_circle1 = plotOutput("visual_circle1"),
                              )
)

networkCom <- htmlTemplate("www/networkCom.html",
                                  netVisual_chord_gene = plotOutput("netVisual_chord_gene"),
                                  source2 = uiOutput("source2"),
                                  target2 = uiOutput("target2"),

                              pathway = uiOutput("pathway"),
                              contribut =  plotOutput("contribut"),)

pathway <- htmlTemplate("www/pathway.html",
                                  netVisual_chord_gene = plotOutput("netVisual_chord_gene"),
                                  source2 = uiOutput("source2"),
                                  target2 = uiOutput("target2"),

                              pathway = uiOutput("pathway"),
                              commcellcell =  plotOutput("commcellcell"),)

router <- make_router(
  route("/", home_page),
  route("communactionCellCell", communactionCellCell),
  route("networkCom", networkCom),
  route("pathway", pathway)
)

# Add ressource css, js and images
pathRessource = paste(getwd(),"/www",sep="")
addResourcePath("www", pathRessource)
ui <- fluidPage(
   # tags$ul(
   # tags$li(a(href = route_link("/"), "www")),
   # tags$li(a(href = route_link("charts"), "charts")),
   # tags$li(a(href = route_link("contribut"), "contribut"))
   # ),
  # tags$head(
  #   tags$style(
  #     HTML(
  #       "body {
  #         background-image: url('www/img/brain.png');
  #       }"
  #     )
  #   )
  # ),
  router$ui,


)
