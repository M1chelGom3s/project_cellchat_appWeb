build:
	sudo docker build -f bin/Dockerfile-setup -t local/rstudio .

run:
	sudo docker run -d -p 8788:8787 -v $(pwd):/home/rstudio -e DISABLE_AUTH=true local/rstudio

all: build run