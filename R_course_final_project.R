suppressPackageStartupMessages(library(tidyverse))
data <- read_csv('BRFSS2015_650.csv', show_col_types = FALSE)

# This is a copy of a school project for a course involving the manipulation of
# dataframes in R. Plotting and basic modeling were also taught.
# The project involved choosing 4 variables from the dataset, cutting them down or altering\
# them to make them easier to work with, removing outliers if applicable, running basic
# plots and summary statistics, and creating two basic models and choosing the best one.

# The data being used is a subset of the 2015.csv from the BRFSS. It does not contain 
# all of the original columns of the 2015.csv, but the columns contained in the one used
# have not been altered in any way. 
# The 2015.csv can be found using this link: 
# https://www.kaggle.com/datasets/cdc/behavioral-risk-factor-surveillance-system?select=2015.csv

# Q10
# FRUITJU1
# 101 - 199 Times per day
# 201 - 299 Times per week
# 301 - 399 Times per month
# 555 - Never
# 777 - Don't know
# 999 - Refused 
# BLANK - Not asked or missing
# I was only interested in the amount of juice consumed per week, so I filtered out everything else and changed 555 to 0 as well 
# as the other values to the numbers they represent (ex 207 = 7). 

# ALCDAY5
# 101 - 199 Days per week
# 201 - 299 Days per month
# 777 - Don't know
# 888 - No drinks in the past month
# 999 - Refused
# BLANK - Not asked or missing
# I was only interested in the days per week, so I filtered out everything else except 888 and again converted the values to the 
# numbers they correspond to. 

# SCNTLWK1
# 1 - 96 Hours
# 97 - don't know
# 98 - 0
# 99 - refused
# Blank - NA
# Removed 97, 99, NA; changed 98 to 0. 

# EXEROFT1
# 101 - 199 Times per week
# 201 - 299 Times per month
# 777 - Don't know
# 999 - Refused
# BLANK - Not asked or missing
# I was only interested in the times per week, so I filtered out everything else and converted the values again to their respective
# numbers. 

# After looking at the boxplots and histograms of the initial data, I discovered the statistics for FRUITJU1 and ALCDAY5 to be heavily influenced by an 
# overwhelming majority of the points being at the 0 value. I decided to remove this value, and analyse the data only for the people who had at least 1
# alcoholic drink and at least 1 fruit drink in the week. 


dfJ <- data %>%
  filter(FRUITJU1 >= 201 & FRUITJU1 <= 299) %>%
  mutate(FRUITJU1 = recode(FRUITJU1, '201' = '1', '202' = '2', '203' = '3', '204' = '4', '207' = '7', '214' = '14',
                           '205' = '5', '206' = '6', '230' = '30', '210' = '10', '220' = '20', '212' = '12', '208' = '8',
                           '215' = '15', '221' = '21', '209' = '9', '211' = '11', '216' = '16', '213' = '13', '225' = '25', 
                           '222' = '22', '242' = '42', '224' = '24', '234' = '34', '231' = '31', '228' = '28', '218' = '18',
                           '227' = '27', '245' = '45')) %>%
  mutate(FRUITJU1 = as.numeric(FRUITJU1)) %>%
  filter(ALCDAY5 >= 101 & ALCDAY5 <= 199) %>%
  mutate(ALCDAY5 = recode(ALCDAY5, '101' = '1', '102' = '2', '103' = '3', '104' = '4', '105' = '5', '106' = '6',
                          '107' = '7')) %>%
  mutate(ALCDAY5 = as.numeric(ALCDAY5)) %>%
  filter(EXEROFT1 >= 101 & EXEROFT1 <= 199) %>%
  mutate(EXEROFT1 = recode(EXEROFT1, '106' = '6', '101' = '1', '103' = '3', '102' = '2', '104' = '4', '105' = '5', '107' = '7',
                           '114' = '14', '110' = '10', '130' = '30', '121' = '21', '115' = '15', '156' = '56', '120' = '20', 
                           '125' = '25', '135' = '35', '118' = '18', '112' = '12', '111' = '11', '109' = '9', '108' = '8', 
                           '128' = '28', '142' = '42', '150' = '50', '116' = '16', '117' = '17', '131' = '31', '140' = '40', 
                           '113' = '13', '175' = '75', '138' = '38', '122' = '22', '132' = '32', '199' = '99', '180' = '80',
                           '184' = '84', '124' = '24', '170' = '70', '127' = '27')) %>%
  mutate(EXEROFT1 = as.numeric(EXEROFT1)) %>%
  filter(between(SCNTLWK1, 1, 96) | SCNTLWK1 == 98) %>%
  mutate(SCNTLWK1 = replace(SCNTLWK1, SCNTLWK1 == 98, 0)) %>%
  select(SCNTLWK1, FRUITJU1, ALCDAY5, EXEROFT1)

# Q11
# I initially used the value at the 99.7 percentile as the upper bound for both EXEROFT1 and FRUITJU1 because there were no outliers on the left of the boxplot. 
# There were still outliers for both at or above the value 10 after that, so I made that the non-inclusive upper bound for both variables. The boxplot showed  
# outliers on both sides for SCNTLWK1, so I took the values for the 99.85 percentile and the .15 percentile. The .15 percentile value was 0, so I just made the 
# upper bound the value corresponding to the 99.85 percentile. The boxplot still showed outliers after that, but I was not convinced after looking at the   
# histogram that I had enough ground to remove them. 
# dfn is the dataset I used for the remainder of the problems.

# plots and values used to aid in the removal of outliers
ggplot(dfJ) +
  geom_boxplot(mapping = aes(FRUITJU1))
ggplot(dfJ) +
  geom_histogram(mapping = aes(FRUITJU1))
quantile(dfJ$FRUITJU1, 0.9970)
ggplot(dfJ) +
  geom_boxplot(mapping = aes(EXEROFT1))
ggplot(dfJ) +
  geom_histogram(mapping = aes(EXEROFT1))
quantile(dfJ$EXEROFT1, 0.9970)


dfn <- dfJ %>%
  filter(EXEROFT1 < 10 & FRUITJU1 < 10 & SCNTLWK1 <= 84.675) 


# Q12
# boxplots and histograms and QQ plots of the variables after removing outliers.
ALC_box <- ggplot(dfn) +
  geom_boxplot(mapping = aes(ALCDAY5))
ALC_hist <- ggplot(dfn) +
  geom_histogram(mapping = aes(ALCDAY5))
ALC_qq <- qqnorm(dfn$ALCDAY5)
ALC_qql <- qqline(dfn$ALCDAY5)

EX_box <- ggplot(dfn) +
  geom_boxplot(mapping = aes(EXEROFT1))
EX_hist <- ggplot(dfn) +
  geom_histogram(mapping = aes(EXEROFT1))
EX_qq <- qqnorm(dfn$EXEROFT1)
EX_qql <- qqline(dfn$EXEROFT1)

FR_box <- ggplot(dfn) +
  geom_boxplot(mapping = aes(FRUITJU1))
FR_hist <- ggplot(dfn) +
  geom_histogram(mapping = aes(FRUITJU1))
FR_qq <- qqnorm(dfn$FRUITJU1)
FR_qql <- qqline(dfn$FRUITJU1)

SC_box <- ggplot(dfn) +
  geom_boxplot(mapping = aes(SCNTLWK1))
SC_hist <- ggplot(dfn) +
  geom_histogram(mapping = aes(SCNTLWK1))
SC_qq <- qqnorm(dfn$SCNTLWK1)
SC_qql <- qqline(dfn$SCNTLWK1)




# Q13
# dataframes of each variable containing standard deviation and variance, and summaries of each variable
FRUITJU1_sdvar <- dfn %>%
  summarise(sd = round(sd(FRUITJU1), 2),
            var = round(var(FRUITJU1), 2)) %>%
  as.data.frame()
FRUITJU1_sum <- round(summary(dfn$FRUITJU1), 2)

EXER_sdvar <- dfn %>%
  summarise(sd = round(sd(EXEROFT1), 2),
            var = round(var(EXEROFT1), 2)) %>%
  as.data.frame()
EXEROFT1_sum <- round(summary(dfn$EXEROFT1), 2)

ALCDAY5_sdvar <- dfn %>%
  summarise(sd = round(sd(ALCDAY5), 2),
            var = round(var(ALCDAY5), 2)) %>%
  as.data.frame()
ALCDAY5_sum <- round(summary(dfn$ALCDAY5), 2)

SCNTLWK1_sdvar <- dfn %>%
  summarise(sd = round(sd(SCNTLWK1), 2),
            var = round(var(SCNTLWK1), 2)) %>%
  as.data.frame()
SCNTLWK1_sum <- round(summary(dfn$SCNTLWK1), 2)


# Q14
mod1 <- lm(ALCDAY5 ~ FRUITJU1, data = dfn)
mod2 <- lm(ALCDAY5 ~ EXEROFT1 + SCNTLWK1, data = dfn)
summary(mod1)
summary(mod2)
AIC(mod1)
AIC(mod2)
# mod1 is the better model

