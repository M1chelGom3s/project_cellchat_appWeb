################################################################################
# server of the app
#
# Author: GOMES Michel
# Created: 04-10-2022 
################################################################################


server <- function(input, output, session) {
  router$server(input, output, session)
  options(shiny.maxRequestSize=3000*1024^2) 

  contents1 <- reactive({
    file <- input$file1
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    
    cellchat = readRDS(file = file$datapath)
    result_try <- try({
      tst = levels(cellchat@idents)
      
      
    }, silent = TRUE)
    if (class(result_try) == "try-error"){
      
    
    # Charger le jeu de données DG
    DG.data = NormalizeData(cellchat)  # L'étape de normalisation consiste à normaliser les mesures d'expression génique pour chaque cellule par l'expression totale, en la multipliant par 10 000 et en transformant le résultat en log.
    
    data.input = GetAssayData(DG.data, assay = "RNA", slot = "data") %>% head(3000)
    labels = Idents(DG.data)
    
    meta = data.frame(labels = labels, row.names = names(labels))
    cellchat = createCellChat(object = data.input, meta = meta, group.by = "labels")

    # definir et importer la base de données des récepteurs de ligands untilisee
    # dans l'objet cellchat@DB
    CellChatDB = CellChatDB.mouse
    # colnames(CellChatDB$interaction)
    CellChatDB.use = subsetDB(CellChatDB, search = "Secreted Signaling")  # Sélectionnez les signalisation secrète pour une analyse ultérieure de l'interaction cellulaire.
    cellchat@DB = CellChatDB.use


    cellchat = subsetData(cellchat)  # extraction des gênes de signalisation de la matrice de comptage

    future::plan("multiprocess", workers = 7)

    # identifier les interactions ligand-recepteur surexprimées
    cellchat = identifyOverExpressedGenes(cellchat)
    cellchat = identifyOverExpressedInteractions(cellchat)
    cellchat = projectData(cellchat, PPI.mouse)

    # Les probabilités d'interaction cellulaire sont déduite des valeurs
    # d'expression

    cellchat = computeCommunProb(cellchat)
    df.net = subsetCommunication(cellchat)
    cellchat = computeCommunProbPathway(cellchat)
    # Compter le nombre (combien de paires de récepteurs ligands) et l'intensité
    # (probabilité) de la communication entre les cellules
    cellchat = aggregateNet(cellchat)
    }
    
    cellchat

    
  })
  resview = reactive({'<div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">View result</h6>
                </div>
                <div class="card-body">
                <div class="my-2"></div>
                    <a  href="./#!/communactionCellCell" class="btn btn-success btn-icon-split">
                        <span class="icon text-white-50">
                            <i class="<i class="fa-solid fa-chart-simple"></i>"></i>
                        </span>
                        <span class="text">plot communication</span>
                    </a>
                <div class="my-2"></div>
                    <a href="./#!/pathway" class="btn btn-info btn-icon-split">
                        <span class="icon text-white-50">
                            <i class="<i class="fa-solid fa-table-layout"></i>"></i>
                        </span>
                        <span class="text">pathway communication</span>
                    </a>
                </div>
            </div>'
  })

  output$nb_cell_type_gene = renderUI({
    resview = resview()
    cellchat = contents1()

    nb_cell_type = levels(cellchat@idents) %>% length()
    nb_gene = cellchat@data %>% as.tibble() %>% ncol()
    nb_cell = cellchat@data %>% as.tibble() %>% nrow()

    contentHtml = paste('<div class="row">
                        <div class="has-animation animation-rtl" data-delay="100">
                            ',resview,'
                        </div>
                        

                        <!-- Nb cells -->
                        <div class="has-animation animation-rtl" data-delay="1000">
                            
                            <div class="card border-left-primary shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                <h5>Nb cells</h5>
                                            </div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800"> ',nb_cell,' </div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fa fa-bar-chart fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- NB genes -->
                        <div class="has-animation animation-rtl" data-delay="1500">
                            <div class="card border-left-success shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                <h5>NB genes </h5>
                                            </div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">',nb_gene,'</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fa fa-bar-chart fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                       
                        <!-- NB cells type -->
                        <div class="has-animation animation-rtl" data-delay="2000">
                            <div class="card border-left-warning shadow h-100 py-2">
                                <div class="card-body">
                                    <div class="row no-gutters align-items-center">
                                        <div class="col mr-2">
                                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                <h5>NB cells types</h5>
                                            </div>
                                            <div class="h5 mb-0 font-weight-bold text-gray-800">',nb_cell_type,'</div>
                                        </div>
                                        <div class="col-auto">
                                            <i class="fa fa-bar-chart fa-2x text-gray-300"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>')
    HTML(contentHtml)

    })
  

    output$source1 = renderUI({
    cellchat = contents1()
    ls_cell = levels(cellchat@idents)
    ligne =  '<div class="mb-3">
        <label for="exampleFormControlSelect1">select source</label><select class="form-control" id="source1">'
    for (i in ls_cell){
      row = paste('<option value="',i,'">',i,'</option>')
      ligne = paste(ligne,row)
      

    }
    ligne = paste(ligne,"</select>
                        </div")
    HTML(ligne)
    
  })
  output$button = renderUI({
    h9= contents1()
    HTML('<a href="#" class="btn btn-success btn-icon-split">
                                        <span class="icon text-white-50">
                                            <i class="fa fa-refresh" role="presentation" aria-label="refresh icon"></i>
                                        </span>
                                        <span class="text">Submit</span>
                                    </a>')

  })

    source1= reactive({
        
        gsub(" ","",input$source1)
    })


    output$result <- renderText({
      paste("You chose 1", source1())
    })

    



  output$visual_circle = renderPlot({
    cellchat = contents1()
      groupSize = as.numeric(table(cellchat@idents))
      source = source1()

      netVisual_circle(cellchat@net$count, vertex.weight = groupSize, weight.scale = T,
    label.edge = F, title.name = "Number of interactions", sources.use = source)


  })
   output$visual_circle1 = renderPlot({
    cellchat = contents1()
    source = source1()
      groupSize = as.numeric(table(cellchat@idents))

      netVisual_circle(cellchat@net$weight, vertex.weight = groupSize, weight.scale = T,
    label.edge = F, title.name = "Interaction weights/strength", sources.use = source)
  })

  

  output$visual_circle_all = renderPlot({
    cellchat = contents1()
      groupSize = as.numeric(table(cellchat@idents))

      netVisual_circle(cellchat@net$count, vertex.weight = groupSize, weight.scale = T,
    label.edge = F, title.name = "All interactions", sources.use = NULL)
  })

  output$source2 = renderUI({
    cellchat = contents1()
    ls_cell = levels(cellchat@idents)
    ligne =  '<div class="mb-3">
        <label for="exampleFormControlSelect1">select source</label><select class="form-control" id="source2">'
    for (i in ls_cell){
      row = paste('<option value="',i,'">',i,'</option>')
      ligne = paste(ligne,row)
      

    }
    ligne = paste(ligne,"</select>
                        </div")
    HTML(ligne)
    
  })


    source2= reactive({
        
        gsub(" ","",input$source2)
    })


    output$target2 = renderUI({
    cellchat = contents1()
    ls_cell = levels(cellchat@idents)
    ligne =  '<div class="mb-3">
        <label for="exampleFormControlSelect1">select target</label><select class="form-control" id="target2">'
    for (i in ls_cell){
      row = paste('<option value="',i,'">',i,'</option>')
      ligne = paste(ligne,row)
      
      

    }
    ligne = paste(ligne,"</select>
                          </div>")
    HTML(ligne)
    
  })

  target2 = reactive({
    gsub(" ","",input$target2)
    print(gsub(" ","",input$target2))
  })
  output$result2 <- renderText({
      paste("You target 1", target2())
    })



  output$netVisual_chord_gene = renderPlot({
    cellchat = contents1()
    source = source2()
    target = target2()
    netVisual_chord_gene(cellchat, sources.use = source, targets.use = target, lab.cex = 1.5,
    legend.pos.y = 30)

  })
  
  output$pathway = renderUI({
    cellchat = contents1()
    pathways.all = cellchat@netP$pathways
    ligne =  '<div class="mb-3">
        <label for="exampleFormControlSelect1">select pathway</label><select class="form-control" id="pathway">'
    for (i in pathways.all){
      row = paste('<option value="',i,'">',i,'</option>')
      ligne = paste(ligne,row)
      
      

    }
    ligne = paste(ligne,"</select>
                          </div>")
    HTML(ligne)
    
  })

  pathway = reactive({
    gsub(" ","",input$pathway)
    print(gsub(" ","",input$pathway))
  })

  
  output$commcellcell = renderPlot({
    cellchat = contents1()
    pathways.show = pathway()
    

    netAnalysis_contribution(cellchat, signaling = pathways.show)
  })


}