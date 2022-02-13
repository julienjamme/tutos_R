# Import French Census 2018 - data by iris (dwellings and diplomas)
# dwellings : https://www.insee.fr/fr/statistiques/fichier/5650749/base-ic-logement-2018_csv.zip
# diplomas : https://www.insee.fr/fr/statistiques/fichier/5650712/base-ic-diplomes-formation-2018_csv.zip
# Require R>4.1.1
# Packages : data.table and dplyr

source("settings_s3.R", encoding = "UTF-8") #S3 connexion settings

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

dipl_tb <- data.table::fread(
  "data/base-ic-diplomes-formation-2018.CSV",
  colClasses = c("IRIS" = "character", "COM" = "character")
)[COM %in% 13201:13216,] |>
  dplyr::as_tibble()
str(dipl_tb)

dw_tb <- data.table::fread(
  "data/base-ic-logement-2018.CSV",
  select = c(
    "IRIS","COM","TYP_IRIS","P18_LOG",
    "P18_RP","P18_RSECOCC","P18_LOGVAC",
    "P18_MAISON","P18_APPART","P18_RP_PROP",
    "P18_RP_LOCHLMV"
  ),
  colClasses = c("IRIS" = "character", "COM" = "character")
)[COM %in% 13201:13216,] |>
  dplyr::as_tibble()
str(dw_tb)

#spatial layers : iris and municipal districts of Marseille

marseille_iris_sf <- 
  aws.s3::s3read_using(
    FUN = sf::st_read,
    object = "fonds/iris_bdtopo_dep_13_2021.gpkg",
    bucket = "julienjamme",
    opts = list("region" = "")
  ) |>
  dplyr::filter(depcom %in% 13201:13216)

str(marseille_iris_sf)

marseille_armf_sf <- 
  aws.s3::s3read_using(
    FUN = sf::st_read,
    object = "fonds/armf_bdtopo_dep_13_2021.gpkg",
    bucket = "julienjamme",
    opts = list("region" = "")
  ) |>
  dplyr::filter(code %in% 13201:13216)

str(marseille_armf_sf)

save(
  dipl_tb, dw_tb, marseille_armf_sf, marseille_iris_sf,
  file = "data/iris_marseille_census_2018_dwell_dipl_and_sf.RData"
)



