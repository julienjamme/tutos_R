
# download.file(url = "https://wxs.ign.fr/c90xknypoz1flvgojchbphgt/telechargement/prepackage/LIDARHD_PACK_NP_2021$LIDARHD_1-0_LAZ_NP-0830_6289-2021/file/LIDARHD_1-0_LAZ_NP-0830_6289-2021.7z",
         # destfile = "data/LIDARHD_1-0_LAZ_NP-0830_6289-2021.7z")
install.packages(c("archive","rlas"))

archive::archive_extract("data/LIDARHD_1-0_LAZ_NP-0830_6289-2021.7z", dir="data/")

rlas::read.las(filter = "-help")
lidar <- rlas::read.las(
  "data/LIDARHD_1-0_LAZ_NP-0830_6289-2021/Semis_2021_0830_6288_LA93_IGN69.laz",
  filter = "-first_only" #onl ReturnNumber == 1
  # select = 'ia'
)
str(lidar)
# Classes ‘data.table’ and 'data.frame':	15447560 obs. of  16 variables:
# $ X                : num  830858 830858 830858 830857 830855 ...
# $ Y                : num  6287000 6287000 6287000 6287000 6287000 ...
# $ Z                : num  3.9 3.82 3.79 3.84 3.8 ...
# $ gpstime          : num  3.06e+08 3.06e+08 3.06e+08 3.06e+08 3.06e+08 ...
# $ Intensity        : int  2851 3317 2826 1869 2694 3508 3895 3689 4778 4926 ...
# $ ReturnNumber     : int  1 1 1 1 1 1 1 1 1 1 ...
# $ NumberOfReturns  : int  1 1 1 1 1 1 1 1 1 1 ...
# $ ScanDirectionFlag: int  1 1 1 1 1 1 1 1 1 1 ...
# $ EdgeOfFlightline : int  0 0 0 0 0 0 0 0 0 0 ...
# $ Classification   : int  1 1 1 1 1 1 1 1 1 1 ...
# $ Synthetic_flag   : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ Keypoint_flag    : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ Withheld_flag    : logi  FALSE FALSE FALSE FALSE FALSE FALSE ...
# $ ScanAngleRank    : int  0 0 0 0 0 0 0 0 0 0 ...
# $ UserData         : int  0 0 0 0 0 0 0 0 0 0 ...
# $ PointSourceID    : int  17 17 17 17 17 17 17 17 17 17

summary(lidar)

# X                Y                 Z              gpstime            Intensity      ReturnNumber  
# Min.   :830000   Min.   :6287000   Min.   :-10.171   Min.   :305555863   Min.   :  297   Min.   :1.000  
# 1st Qu.:830265   1st Qu.:6287207   1st Qu.:  6.287   1st Qu.:305555876   1st Qu.: 1118   1st Qu.:1.000  
# Median :830444   Median :6287519   Median :  8.755   Median :305555891   Median : 1832   Median :1.000  
# Mean   :830486   Mean   :6287501   Mean   : 10.939   Mean   :305556346   Mean   : 1911   Mean   :1.272  
# 3rd Qu.:830717   3rd Qu.:6287771   3rd Qu.: 15.031   3rd Qu.:305557407   3rd Qu.: 2621   3rd Qu.:1.000  
# Max.   :831000   Max.   :6288000   Max.   : 35.725   Max.   :305557433   Max.   :65535   Max.   :5.000  
# NumberOfReturns ScanDirectionFlag EdgeOfFlightline Classification   Synthetic_flag   Keypoint_flag   
# Min.   :1.000   Min.   :0.0000    Min.   :0        Min.   : 1.000   Mode :logical    Mode :logical   
# 1st Qu.:1.000   1st Qu.:0.0000    1st Qu.:0        1st Qu.: 1.000   FALSE:15447560   FALSE:15447560  
# Median :1.000   Median :1.0000    Median :0        Median : 1.000                                    
# Mean   :1.543   Mean   :0.5259    Mean   :0        Mean   : 1.002                                    
# 3rd Qu.:2.000   3rd Qu.:1.0000    3rd Qu.:0        3rd Qu.: 1.000                                    
# Max.   :5.000   Max.   :1.0000    Max.   :0        Max.   :28.000                                    
# Withheld_flag    ScanAngleRank        UserData PointSourceID 
# Mode :logical    Min.   :-19.000   Min.   :0   Min.   :17.0  
# FALSE:15447560   1st Qu.:-15.000   1st Qu.:0   1st Qu.:17.0  
# Median :-10.000   Median :0   Median :17.0  
# Mean   : -8.882   Mean   :0   Mean   :17.3  
# 3rd Qu.: -3.000   3rd Qu.:0   3rd Qu.:18.0  
# Max.   :  4.000   Max.   :0   Max.   :18.0  

quantile(lidar$Classification, probs = seq(0,1,0.05))
quantile(lidar$Intensity, probs = seq(0,1,0.05))

lidar[Classification==28,]
lidar[Intensity > 20000,]

library(ggplot2)

set.seed(1234)
rows_sel <- sample.int(nrow(lidar), size = 100000)
summary(lidar[rows_sel,])

lidar_sel <- lidar[rows_sel,][Classification!=28 & Intensity < 3678,]

ggplot(lidar_sel, aes(x=X,y=Y)) +
  geom_point(aes(color=Z), size = 0.1) +
  scale_color_viridis_c() +
  ggtitle("Elévation") +
  theme_void()

ggplot(lidar_sel, aes(x=X,y=Y)) +
  geom_point(aes(color=Intensity), size = 0.1) +
  scale_color_viridis_c() +
  ggtitle("Intensité") +
  theme_void()

ggplot(lidar_sel, aes(x=X,y=Y)) +
  geom_point(aes(color=as.factor(Classification)), size = 0.1) +
  scale_color_viridis_d("Classification") +
  ggtitle("Classification") +
  theme_void()
  
ggplot(lidar_sel, aes(x=X,y=Y)) +
  geom_point(aes(color=gpstime), size = 0.1) +
  scale_color_viridis_c("gpstime") +
  ggtitle("gpstime") +
  theme_void()

