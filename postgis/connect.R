
library(DBI)
library(RPostgres)
library(dplyr)
library(dbplyr)

source("user_pass.R", encoding = "UTF-8")

connecter <- function(user, password){
  nom <- "defaultdb"
  hote <- "postgresql-806042"
  port <- "5432"
  conn <- dbConnect(Postgres(), dbname=nom, host=hote, user=user, password=password,port=port)
  return(conn)
}

conn <- connecter(user, password)

DBI::dbListObjects(conn)

parcelles_rpg_R28 <- sf::st_read("../../work/RPG_2-0__SHP_LAMB93_R28_2021-01-01/RPG/1_DONNEES_LIVRAISON_2020/RPG_2-0_SHP_LAMB93_R28_2020/PARCELLES_GRAPHIQUES.shp")
parcelles_rpg_FR_01 <- sf::st_read("../../work/RPG_2-0__SHP_LAMB93_R28_2021-01-01/RPG/1_DONNEES_LIVRAISON_2020/RPG_2-0_SHP_LAMB93_R28_2020/PARCELLES_GRAPHIQUES.shp")
parcelles_rpg_FR_02 <- sf::st_read("../../work/RPG_2-0__SHP_LAMB93_R28_2021-01-01/RPG/1_DONNEES_LIVRAISON_2020/RPG_2-0_SHP_LAMB93_R28_2020/PARCELLES_GRAPHIQUES.shp")

# sf::st_write(parcelles_rpg_R28, dsn = "parcelles_rpg_R28_2020.gpkg")

aws.s3::s3write_using(
  parcelles_rpg_R28,
  FUN = sf::st_write,
  delete_layer = TRUE,
  col.names = TRUE,
  object = "ign/parcelles_rpg_R28_2020.gpkg",
  bucket = "julienjamme",
  opts = list("region" = "")
)

aws.s3::s3write_using(
  parcelles_rpg_FR_01,
  FUN = sf::st_write,
  delete_layer = TRUE,
  col.names = TRUE,
  object = "ign/parcelles_rpg_FR01_2020.gpkg",
  bucket = "julienjamme",
  opts = list("region" = "")
)

aws.s3::s3write_using(
  parcelles_rpg_FR_02,
  FUN = sf::st_write,
  delete_layer = TRUE,
  col.names = TRUE,
  object = "ign/parcelles_rpg_FR02_2020.gpkg",
  bucket = "julienjamme",
  opts = list("region" = "")
)
