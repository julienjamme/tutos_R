
# Créer et manipuler une liste
list_1 <- list(2:3, 4:5, 6:7, 8:9)
list_1
length(list_1)

# index
list_1[2] 
list_1[[2]]
class(list_1[2]) # liste
class(list_1[[2]]) # vecteur

list_1[2:3]
list_1[c(2,4)] 
list_1[c(2,5)] # 5 > longueur de la liste => crée un élément NULL
length(list_1[c(2,5)]) # de longueur 2

list_1[-3] # tous les éléments sauf le 3eme
list_1[c(-1,-3)]

# Supprimer un élément de la liste
list_1[3] <- NULL
list_1
length(list_1)

# Ajouter un élément en fin de liste
# Fonction append() pour ajouter un élément en fin de liste (équivalent python)
new_element <- list(Lettres = LETTERS[2:5])
(list_1_agrandie <- append(list_1, new_element))
# on peut choisir sa localisation
(list_1_agrandie <- append(list_1, new_element, after = 2))
# et la fonction prepend pour ajouter un élément au début (ou avant un élément)
(list_1_agrandie_debut <- purrr::prepend(list_1, new_element)) 

# Accéder à un élément d'un élément de la liste
list_1[[1]][2] # second élément du vecteur qui compose le premier élément de la liste

# donner des noms aux éléments de la liste
names(list_1) <- paste0("vec_", 1:length(list_1))
names(list_1)
list_1
identical(list_1$vec_2,list_1[[2]]) # pour vérifier que deux objets sont identiques à tous points de vue

# Dans une liste on peut mélanger les types d'éléments

list_res <- list(
  data = cars,
  reg = lm(speed ~ dist, data = cars)
)
list_res
names(list_res)

list_res[["fits"]] <- fitted(list_res$reg) # ou fitted(list_res[["reg"]]
list_res

# Passer d'une liste à un vecteur (quand c'est pertinent)
(vec_1 <- unlist(list_1))
(vec_2 <- unlist(list_res)) # attention au résultat ici
# Retirer les noms d'une liste
(list_1_wo_names <- unname(list_1))

# lapply : Réaliser la même opération sur tous les éléments d'une liste
list_df <- list(
  df1 = cars,
  df2 = mtcars,
  df3 = iris,
  df4 = CO2
)

# Obtenir les dimensions de chacun des tableaux
lapply(
  list_df, # la liste 
  dim # la fonction qui s'appliquera sur chaque élémet de la liste
)

list_dim <- lapply(list_df, dim)
names(list_dim)
length(list_dim)
list_dim$df2[2]


# appliquer une fonction anonyme

set.seed(12021934)

new_list_df <- lapply(
  list_df,
  function(df){
    df_select <- head(df)
    df_select$rand <- sample(1:100, 6)
    return(df_select)
  }
)

str(new_list_df)
lapply(new_list_df, dim)

# Appliquer une fonction à partir des noms des éléments de la liste
new_list_df_2 <- lapply(
  names(list_df),
  function(name){
    df_select <- head(list_df[[name]])
    df_select$TAB <- name
    return(df_select)
  }
)

str(new_list_df_2)
lapply(new_list_df_2, dim)

# Avec purrr, la fonction équivalente au lapply est purrr::map()

new_list_df_3 <- purrr::map(
  names(list_df),
  function(name){
    df_select <- head(list_df[[name]])
    df_select$TAB <- name
    return(df_select)
  }
)
identical(new_list_df_2, new_list_df_3)

# cheatsheet purrr -
# https://raw.githubusercontent.com/rstudio/cheatsheets/master/purrr.pdf

# fonctionnement

lapply(list_1, function(arg) arg)
lapply(list_1, function(arg) arg[1])
lapply(list_1, sum)

# Autres opérations sur les listes: rassembler les éléments en un seul

# Exemple: nous souhaitons empiler plusieurs tableaux 

# Création des tableaux avec un lapply
set.seed(04081789)
list_df_2 <- lapply(
  1:10,
  function(num){
    data.frame(
      tab = num,
      x = sample(1:100, 100, replace = TRUE),
      y = rnorm(100)
    )
  }
)
names(list_df_2) <- paste0("T",1:10)

lapply(list_df_2, dim)

# Empilement - trois versions

res_call <- do.call("rbind", list_df_2) # do.call
res_reduce <- Reduce(rbind, list_df_2) # Reduce - base R
res_purrr <- purrr::reduce(list_df_2, rbind) # reduce de purrr

all_res <- list(call=res_call,base_red=res_reduce,purrr_red=res_purrr)
lapply(all_res, head) # do.call renomme les lignes de manière particulière
lapply(all_res, dim)



# Associer map et reduce est très courant
# map = appliquer une fonction sur chaque élément de la liste (résultat = liste)
# reduce = sur la liste résultat du map, appliquer une fonction pour les unir en un seul objet

# Cas typique traiter chaque df d'une liste puis empiler les résultats
# purrr::map_dfr

res_map_dfr <- purrr::map_dfr(
  1:10,
  function(num){
    data.frame(
      tab = num,
      x = sample(1:100, 100, replace = TRUE),
      y = rnorm(100)
    )
  }
)
str(res_map_dfr)
table(res_map_dfr$tab)

# Beaucoup de fonctions du package purrr permettent 
# des usages avancés

# exemple
purrr::imap(
  list_df_2, 
  function(df, index){
    df <- head(df)
    df$TAB <- index
    return(df)
})

# une fonction très utile : purrr::walk()

purrr::walk(list_df_2, str)
# notez la différence avec 
purrr::map(list_df_2, str)

# la première retourne la liste de départ de manière invisible
# la seconde retourne un résultat sous forme de liste

return_walk <- purrr::walk(list_1, str)
return_walk

return_map <- purrr::map(list_1, str)
return_map

# purrr::walk() idéal pour les fonctions telles que str() ou print()


# travailler sur deux listes en même temps

list_map2 <- purrr::map2(
  list_df_2,
  sample(1:100, 10, replace = TRUE),
  function(df, seuil){
    df$seuil <- seuil
    df[df$x < seuil,]
  }
)

lapply(list_map2, dim)
sapply(list_map2, function(df) unique(df$seuil))






# Un dataframe est une liste

str(mtcars)
class(mtcars[1]) # accès la première colonne comme dataframe
class(mtcars[[1]]) # acces à la première colonne comme veteur

# travailler sur toutes les colonnes
lapply(mtcars, mean) # résultat sous forme de liste
sapply(mtcars, sd) # résultat sous forme de vecteur

res_lapply <- lapply(mtcars, function(col) scale(col))
str(res_lapply) # chaque colonne est traitée comme une matrice colonne

# purrr::map_dfc recolle les colonnes pour faire un dataframe
res_map_dfc <- purrr::map_dfc(mtcars, function(col) scale(col))
str(res_map_dfc)

# Bien entendu, dans ce cas, l'option à privilégier (hors dplyr::across)
# c'est la fonction apply
# apply : pour travailler sur des matrices (ou des dataframe dont les colonnes sont du même type)

res_apply <- apply(mtcars, MARGIN = 2, FUN = scale)
str(res_apply) # résultat matrice
# MARGIN = 2 : l'opération renseignée dans FUN est appliquée à chaque colonne l'une après l'autre
# => en sortie l'objet possède autant de colonnes que la matrice de départ
# MARGIN = 1 : l'opération est appliquée sur chaque ligne
# => en sortie l'objet possède autant de lignes que la matrice de départ

apply(mtcars, 2, mean)
apply(mtcars, 1, mean)







