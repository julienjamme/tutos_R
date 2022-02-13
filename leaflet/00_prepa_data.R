# Import French Census 2018 - data by iris (dwellings and diplomas)
# dwellings : https://www.insee.fr/fr/statistiques/fichier/5650749/base-ic-logement-2018_csv.zip
# diplomas : https://www.insee.fr/fr/statistiques/fichier/5650712/base-ic-diplomes-formation-2018_csv.zip

list_files <- list(dw = list(name = "base-ic-logement-2018_csv", num = "5650749"),
                   di = list(name = "base-ic-diplomes-formation-2018_csv", num = "5650712")
)

lapply(
  list_files,
  function(x){
    zip_file <- paste0("data/",x$name,".zip")
    download.file(
      paste0("https://www.insee.fr/fr/statistiques/fichier/",x$num,"/",x$name,".zip"),
      destfile = zip_file
    )
    unzip(zip_file,exdir = "data/")
  }
)


dw_tb <- data.table::fread(
  "data/base-ic-diplomes-formation-2018.CSV", nrows = 1000
)
str(dw_tb)

