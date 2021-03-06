library(readxl)
library(tidyverse)
library(reshape2)
library(xts)
library(dygraphs)
library(plotly)
library(quantmod)
library(knitr)
library(kableExtra)
theme_set(theme_classic())

#OPTION
options(crayon.enabled = FALSE)
options(stringsAsFactors=FALSE)

# PLOSHING TICKERS IN MASTER 
MASTER <- read_excel('./DATA/RAW/MASTER.xlsx')
MASTER <- rename(MASTER, f_code = full_code)
MASTER <- data.frame(MASTER[,-1])

# PLOSHING TICKERS IN MASTER
NAVER_IDST <- read_excel('./DATA/RAW/NAVER_INDUSTRY.xlsx', sheet='STOCK')
NAVER_IDST <- data.frame(NAVER_IDST[-1])
NAVER_IDST <- rename(NAVER_IDST, s_code = X1)

# POLISHING INDEX
INDEX_ALL <- read.csv('./DATA/RAW/INDEX.csv')
colnames(INDEX_ALL) <- c('date', 'KOSDAQ', 'KOSPI')
INDEX_ALL[['date']] <- as.Date(INDEX_ALL[['date']])
INDEX_ALL <- arrange(INDEX_ALL, date)

# PLOSHING KRX_DATA
KRX_DATA_ALL <- read.csv('./DATA/RAW/KRX_DATA_ALL.csv')
KRX_DATA_ALL <- rename(KRX_DATA_ALL, f_code = ticker)
KRX_DATA_ALL <- left_join(KRX_DATA_ALL, MASTER, by = "f_code")
KRX_DATA_ALL <- rename(KRX_DATA_ALL, s_code = short_code)
KRX_DATA_ALL <- left_join(KRX_DATA_ALL, NAVER_IDST, by = "s_code")
KRX_DATA_ALL <- rename(KRX_DATA_ALL, sector = X2)
KRX_DATA_ALL <- rename(KRX_DATA_ALL, name = codeName)
KRX_DATA_ALL[,"X0"] <- NULL
KRX_DATA_ALL <- filter(KRX_DATA_ALL, vol_s!=0)
KRX_DATA_ALL <- rename(KRX_DATA_ALL, date = X)
KRX_DATA_ALL[,'date'] <- as.Date(KRX_DATA_ALL[,'date'])
KRX_DATA_ALL[,'cap_mil'] <- KRX_DATA_ALL[,'cap_mil'] * 1000000

# PICK BIO FROM KRX_DATA
KRX_DATA_BIO <- filter(KRX_DATA_ALL, sector == "PHM" | sector == "BIO")

# SPLIT BY NAME
KRX_DATA_BIO_bycode <- split(KRX_DATA_BIO, KRX_DATA_BIO[,'name'])