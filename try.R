library(dplyr)
library(httr)
library(jsonlite)
library(openxlsx)

source("utils/crawler_cht_people.R", encoding = "UTF-8")

# set grid Ids and data variables -------------------------------------------

## use following site to find gridIDs:
# http://202.39.224.156/RCTA/Home/Index
# account: ethan
# pw: ethan123

## Get gridID
gridIDs = c(Breez_SongGao = "385019",
            BELLAVITA = "384533",
            ATT4FUN = "385022",
            RaoHe_NightMarket = "384957",
            ShiLin_NightMarket = "396290",
            ShiDa_NightMarket = "384885",
            GongGuan_NightMarket = "384086",
            BanJi = "385019",
            Metro_TP_CityHall = "385020",
            SanYue_XinYi = "384533"
            )

stats_vec <- c("Grid_POPULATION",
               "Grid_Age",
               "Grid_CT",
               "Grid_Sex",
               "Grid_NT",
               "Grid_ShoppingAndCosmetic",
               "Grid_TravelAndMovieAndExercise",
               "Grid_TechAndHNWI"
)


# Go! ---------------------------------------------------------------------

result_tbl <- cht_crawler(gridIDs, stats_vec,
                          time_period =  c("20151119000000", "20151125235900"))
result_tbl %>% write.xlsx("result/cht_people_data.xlsx")
