# beta cellchat application web

G protein-coupled receptors (GPCRs) are particularly attractive as the most favorable targets for new therapies, but this approach depends essentially on the identification of their endogenous agonists. The search for drug targets in the brain has traditionally focused on neurons, but astrocytes as natural neuroprotectors represent particularly interesting drug targets.

Astrocytes are glial cells and the most common cell type in the CNS, accounting for 20-50% of glia volume.
They play a number of roles in the CNS. 
Microglial cells, the second type of glial cells in the brain and spinal cord. Microglia inhabit approximately 5-20% of the mammalian brain and are constantly on the move in the CNS, engaging in extracellular signaling and identifying damaged neurons and infectious agents to maintain homeostasis. They are the first line of defense in brain pathologies, acting as macrophages that engulf and digest damaged or infected cells. The role of microglia is essentially defensive.

However, the immune response activity of microglial cells is a double-edged sword. Specifically, after being activated, microglia can release chemicals into the extracellular space to activate more microglia and can damage cells and cause neuronal cell death. 

## Objectif



Here, the objective is to create a web application to calculate and visualize possible interactions between microglial cells and astrocytes.

The analysis of the Cellchat model is adapted from the code of Suoqin Jin [(Inference and analysis of cell-cell communication using CellChat)](https://htmlpreview.github.io/?https://github.com/sqjin/CellChat/blob/master/tutorial/CellChat-vignette.html).

We will therefore use CellChat an R package designed to study intercellular communications from scRNA-seq data, CellChat provides functionality for data exploration, analysis and visualization.


## Shiny app

The application is under development.

![me](https://github.com/M1chelGom3s/project_cellchat_appWeb/blob/master/www/img/overview.gif)
This web application is written using the [R Shiny](https://shiny.rstudio.com/) web framework. It demonstrates the use of custom HTML templates in Shiny apps to create a fancy user experience. The theme used in this app is offered by [bootstrap](https://getbootstrap.com/). 

Note that the application was inspired by the shiny application [ShIVA](https://www.biorxiv.org/content/10.1101/2022.09.20.508636v1) by Muhammad Asif, Sabrina Chenag, Sébastien Jaeger, Pierre Milpied and Lionel Spinelli.


## Data test

[the gyrus danté cell dataset](https://we.tl/t-kwFjilaS2X). The cell populations are annotated and created from Seurat (V3).



## Setup development environment

The development environment of this project can be encapsulated in a Docker container.
To avoid any library dependency problem, it is preferable to follow the following instructions and launch the application in a container

1. Install Docker. Follow the instructions on [https://docs.docker.com/install/](https://docs.docker.com/install/)
2. Open a console (or a terminal on a Mac). On Windows you can use Bash which comes with the installation of Git. Clone the GIT repository:
    ```
    git clone https://github.com/M1chelGom3s/project_cellchat_appWeb.git

3. Setup development Docker container:
    ```
    cd project_cellchat_appWeb | chmod +x *
    bin/setup-environment.sh
    ```
    You should see lots of container build messages. Building the container might take a few minutes.
4. On Linux or Mac spin up the container using:
    ```
    bin/start_rstudio.sh
    ```
    On Windows run instead:
    ```
    bin/start_rstudio_win.sh
    ```
5. Open [http://localhost:8788](http://localhost:8788) in your browser to start a new RStudio session

6. Open the file `app.R` and hit the "Run ALL" button in the toolbar of the script editor (or CTRL+Alt+R` in the R session window). The Shiny app should open in a new window. You may need to instruct your browser to not block popup windows for this URL.


## Deployment

The app is deployed through RStudio's webservice [shinyapps.io](https://shinyapps.io/). 
The 'CellChat' package has been compiled under R 4.1.3.
