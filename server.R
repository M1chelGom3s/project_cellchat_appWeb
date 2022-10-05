################################################################################
# UI of the app
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
  output$resview = renderUI({
    action1 = contents1()
    HTML('<div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">View result</h6>
                </div>
                <div class="card-body">
                    <!--<p>Works with any button colors, just use the <code>.btn-icon-split</code> class and
                        the markup in the examples below. The examples below also use the
                        <code>.text-white-50</code> helper class on the icons for additional styling,
                        but it is not required.</p>
                    <a href="#" class="btn btn-primary btn-icon-split">
                        <span class="icon text-white-50">
                            <i class="fas fa-flag"></i>
                        </span>
                        <span class="text">Split Button Primary</span>
                    </a>-->
                <div class="my-2"></div>
                    <a  href="./#!/charts" class="btn btn-success btn-icon-split">
                        <span class="icon text-white-50">
                            <i class="fas fa-check"></i>
                        </span>
                        <span class="text">plot communication</span>
                    </a>
                <div class="my-2"></div>
                    <a href="./#!/contribut" class="btn btn-info btn-icon-split">
                        <span class="icon text-white-50">
                            <i class="fas fa-info-circle"></i>
                        </span>
                        <span class="text">contribut communication</span>
                    </a>
                </div>
            </div>')
  })
  output$nb_cell = renderText({
    cellchat = contents1()
    cellchat@data %>% as.tibble() %>% nrow()
    
  })
  
  output$nb_gene = renderText({
    cellchat = contents1()
    
    cellchat@data %>% as.tibble() %>% ncol()
    
  })

  output$nb_cellType = renderText({
    cellchat = contents1()

    levels(cellchat@idents) %>% length()
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
    label.edge = F, title.name = "Number of interactions", sources.use = NULL)
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