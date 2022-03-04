
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

sf::st_write(
  obj = parcelles_rpg_R28 |> rename_with(tolower),
  dsn = conn,
  Id(schema = 'parcelles_rpg', table = 'r28'),
  append = TRUE
)

r28_head <- dbGetQuery(conn, 'SELECT * FROM parcelles_rpg.r28 LIMIT 10;')
r28_head_sf <- st_read(conn, 'SELECT * FROM parcelles_rpg.r28 LIMIT 10;')

# FRANCE METROPOLITAINE

parcelles_rpg_FR <- sf::st_read("../../RPG_2-0_2-0_GPKG_LAMB93_FR_2021-01-01/RPG/1_DONNEES_LIVRAISON_2020/RPG_2-0_GPKG_LAMB93_FR_2020/PARCELLES_GRAPHIQUES.gpkg")
str(parcelles_rpg_FR)

# CLOUD STORAGE

aws.s3::s3write_using(
  parcelles_rpg_FR,
  FUN = sf::st_write,
  delete_layer = TRUE,
  col.names = TRUE,
  object = "ign/parcelles_rpg_FR_2020.gpkg",
  bucket = "julienjamme",
  opts = list("region" = "")
)

# DB STORAGE

query <- 'CREATE TABLE parcelles_rpg.fr
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

sf::st_write(
  obj = parcelles_rpg_FR |> rename_with(tolower),
  dsn = conn,
  Id(schema = 'parcelles_rpg', table = 'fr'),
  append = TRUE
)

fr_head <- dbGetQuery(conn, 'SELECT * FROM parcelles_rpg.fr LIMIT 10;')
fr_head_sf <- st_read(conn, 'SELECT * FROM parcelles_rpg.fr LIMIT 10;')



