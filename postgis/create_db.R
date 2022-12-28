library(DBI)
library(RPostgres)
library(Rpos)
library(dplyr)
library(dbplyr)
library(sf)

source("user_pass.R", encoding = "UTF-8")

connecter <- function(user, password){
  nom <- "db_tpcarto"
  hote <- "10.233.106.178"
  port <- "5432"
  conn <- dbConnect(Postgres(), dbname=nom, host=hote, user="tpcarto", password="tpcarto",port=port)
  return(conn)
}

conn <- connecter(user, password)

DBI::dbListObjects(conn)

# NORMANDY

parcelles_rpg_R28 <- sf::st_read("../../work/RPG_2-0__SHP_LAMB93_R28_2021-01-01/RPG/1_DONNEES_LIVRAISON_2020/RPG_2-0_SHP_LAMB93_R28_2020/PARCELLES_GRAPHIQUES.shp")
str(parcelles_rpg_R28)

aws.s3::s3write_using(
  parcelles_rpg_R28,
  FUN = sf::st_write,
  delete_layer = TRUE,
  col.names = TRUE,
  object = "ign/parcelles_rpg_R28_2020.gpkg",
  bucket = "julienjamme",
  opts = list("region" = "")
)

conn <- connecter(user, password)

query <- 'CREATE TABLE parcelles_rpg.r28
  (id_parcel VARCHAR(8),
  surf_parc REAL,
  code_cultu CHAR(3),
  code_group VARCHAR(2),
  culture_d1 CHAR(3),
  culture_d2 CHAR(3),
  geometry GEOMETRY(MULTIPOLYGON, 2154)
  );
'

dbSendQuery(conn, query)
dbListTables(conn)