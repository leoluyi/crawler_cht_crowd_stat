library(dplyr)
library(httr)
library(jsonlite)
library(openxlsx)

source("utils/bind_rows_with_names.R", encoding = "UTF-8")

# login -------------------------------------------------------------------

headers_common <- add_headers(
  Accept="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  `Accept-Encoding`="gzip, deflate",
  `Accept-Language`="en-GB,en-US;q=0.8,en;q=0.6",
  `Connection`="keep-alive",
  `User-Agent` = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.86 Safari/537.36"
)

login <- POST("http://202.39.224.156/RCTA/Home/Index",
              headers_common,
              add_headers(
                `Cache-Control`="max-age=0",
                `Content-Type`="application/x-www-form-urlencoded",
                # Host="202.39.224.156",
                # Origin="http://202.39.224.156",
                Referer = "http://202.39.224.156/RCTA/"
              ),
              body = "txtAccount=ethan&txtPassword=ethan123"
)
# headers(login)
# gsub("path=/; HttpOnly$", "", headers(login)[4][[1]])


login_cookie <- paste0(gsub("path=/; HttpOnly$", "", headers(login)[4][[1]]),
                       gsub("; path=/$", "", headers(login)[7][[1]]),
                       collapse = "")

# POST("http://202.39.224.156/RCTA/location/_GetAdder",
#      headers_common,
#      add_headers(
#        `Content-Type`="application/x-www-form-urlencoded; charset=UTF-8",
#        Cookie = login_cookie,
#        `X-Requested-With`="XMLHttpRequest"
#      ),
#      body = URLencode("queryAdder=臺北市信義區")
# ) %>% content("text")

# get data functions -------------------------------------------------------

get_single_stat <- function (stat, gridID, time_period) {
  # stat <- "Grid_ShoppingAndCosmetic"
  # gridID = "384533"
  # time_period = c("20151119000000", "20151121235900")
  res <- POST(sprintf("http://202.39.224.156/RCTA/CrowdAnalysis/_CrowdStatistics_%s", stat),
              headers_common,
              add_headers(
                `Content-Length`="63",
                `Content-Type`="application/x-www-form-urlencoded; charset=UTF-8",
                Cookie = login_cookie
                # ,Host = "202.39.224.156",
                # Origin = "http://202.39.224.156"
              ),
              body = URLencode(sprintf("gridIDs=%s&type=0&sDate=%s&eDate=%s",
                                       gridID, time_period[[1]], time_period[[2]]))
  )
  pop <- content(res, "text") %>%
    fromJSON %>%
    mutate(date_time = paste(paste(yyyy, mm, dd, sep="-"), sprintf("%s:00", hh))) %>%
    mutate(date_time = as.POSIXct(strptime(date_time, "%Y-%m-%d %H:%M"),
                                  origin = "1970-01-01",
                                  tz = "Asia/Taipei")) %>%
    select(-c(TIME, yyyy, mm, dd, hh))
  pop
}


get_stats <- function (gridID, time_period, stats_vec) {
  sapply(stats_vec,
         FUN = get_single_stat,
         gridID = gridID,
         time_period =  time_period,
         simplify = FALSE, USE.NAMES = TRUE) %>%
    Reduce(function(x, y) dplyr::full_join(x, y, by = "date_time"), .) %>%
    tbl_df
}

cht_crawler <- function (gridIDs, stats_vec, time_period) {
  # gridID = "384533"
  # stat <- "Grid_ShoppingAndCosmetic"
  # time_period = c("20151119000000", "20151121235900")
  result_tbl <- sapply(gridIDs, get_stats,
                       time_period = time_period,
                       stats_vec = stats_vec,
                       simplify = FALSE, USE.NAMES = TRUE) %>%
    bind_rows_with_names()

  result_tbl
}
