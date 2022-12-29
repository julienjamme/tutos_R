library(DBI)
library(RPostgres)
library(Rpos)
library(dplyr)
library(dbplyr)
library(sf)

# source("user_pass.R", encoding = "UTF-8")

connecter <- function(user, password){
  nom <- "db_tpcarto"
  hote <- "10.233.106.178"
  port <- "5432"
  conn <- dbConnect(Postgres(), dbname=nom, host=hote, user="tpcarto", password="tpcarto",port=port)
  return(conn)
}

conn <- connecter(user, password)

DBI::dbListObjects(conn)

# Téléchargement de la BPE 2021
temp <- tempfile()
download.file("https://www.insee.fr/fr/statistiques/fichier/3568638/bpe21_ensemble_xy_csv.zip",temp)
bpe21 <- readr::read_delim(unz(temp, "bpe21_ensemble_xy.csv"), delim = ";", col_types = readr::cols(LAMBERT_X="n",LAMBERT_Y="n",.default="c"))
str(bpe21)
unlink(temp)
table(is.na(bpe21$LAMBERT_X))
table(is.na(bpe21$LAMBERT_Y))

# On transforme le data en un objet sf (avec géométrie)
sf_bpe21_metro <- bpe21 %>% 
  na.omit() %>% 
  filter(REG > 10) %>% 
  mutate(id = 1:n()) %>% 
  relocate(id) %>% 
  sf::st_as_sf(coords = c("LAMBERT_X","LAMBERT_Y"), crs = 2154)

str(sf_bpe21_metro)  



# Construction de la requête créant les tables
types_vars_metro <- purrr::map_chr(
  names(sf_bpe21_metro)[-c(1,24)],
  function(var){
    paste0(var, " VARCHAR(", max(nchar(sf_bpe21_metro[[var]])), "), ")
  }
) %>% 
  paste0(., collapse="")

query <- paste0(
  'CREATE TABLE bpe21_metro',
  '( id INT PRIMARY KEY,',
  types_vars_metro,
  'geometry GEOMETRY(POINT, 2154));',
  collapse =''
)

# Création de la table
dbSendQuery(conn, query)
dbListTables(conn)

# Remplissage avec la table metro
sf::st_write(
  obj = sf_bpe21_metro %>% rename_with(tolower),
  dsn = conn,
  Id(table = 'bpe21_metro'),
  append = TRUE
)

# test lecture
bpe_head<- sf::st_read(conn, query = 'SELECT * FROM bpe21_metro LIMIT 10;')
str(bpe_head)
st_crs(bpe_head)

# Pour les DOM
sf_bpe21_doms <- purrr::map2(
  c("01","02","03","04"), #pas de données géolocalisées sur Mayotte
  c(5490,5490,2972,2975),
  function(reg,epsg){
    bpe21 %>% 
      filter(REG == reg) %>% 
      na.omit() %>% 
      mutate(id = 1:n()) %>% 
      relocate(id) %>% 
      sf::st_as_sf(coords = c("LAMBERT_X","LAMBERT_Y"), crs = epsg)
  }
)
names(sf_bpe21_doms) <- c("01","02","03","04")

purrr::walk2(
  c("01","02","03","04"), #pas de données géolocalisées sur Mayotte
  c(5490,5490,2972,2975),
  function(reg,epsg){
    nom_table <- paste0('bpe21_',reg)
    types_vars <- purrr::map_chr(
      names(sf_bpe21_doms[[reg]])[-c(1,24)],
      function(var){
        paste0(var, " VARCHAR(", max(nchar(sf_bpe21_doms[[reg]][[var]])), "), ")
      }
    ) %>% 
      paste0(., collapse="")
    
    query <- paste0(
      'CREATE TABLE ',nom_table,
      '( id INT PRIMARY KEY,',
      types_vars,
      'geometry GEOMETRY(POINT, ', epsg,'));',
      collapse =''
    )
    
    sf::st_write(
      obj = sf_bpe21_doms[[reg]] %>% rename_with(tolower),
      dsn = conn,
      Id(table = nom_table),
      append = FALSE
    )
  }
)
dbListTables(conn)

bpe_head<- sf::st_read(conn, query = 'SELECT * FROM bpe21_04 LIMIT 10;')
str(bpe_head)
st_crs(bpe_head)

dbDisconnect(conn)

# Ajout de fonds de polygones

# Recupération sur Minio

sf_reg_metro <- aws.s3::s3read_using(
  FUN = sf::st_read,
  layer = "commune_francemetro_2021.shp",
  drivers = "ESRI Shapefile",
  # Mettre les options de FUN ici
  object = "/fonds/commune_francemetro_2021.shp",
  bucket = "julienjamme",
  opts = list("region" = "")
)
sf_reg_metro %>% str()

