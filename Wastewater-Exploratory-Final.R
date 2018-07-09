library(ggplot2)
library(dplyr)
library(lubridate)

## Read data into R and save raw data
WWTP1 <- read.csv("WWTP1.csv", stringsAsFactors = FALSE, 
                  na.strings = c("", "-", "no sample", "No data", "no data"))

WWTP2 <- read.csv("WWTP2.csv", stringsAsFactors = FALSE, 
                  na.strings = c("", "-", "no sample", "No data", "no data"))

rawdata <- tbl_df(rbind(
        mutate(WWTP1, Source = as.factor("WWTP-1")),
        mutate(WWTP2, Source = as.factor("WWTP-2")) 
))
remove(WWTP1, WWTP2)

## Save compiled raw data
parameters <- c("BOD", "TSS", "OG", "pH", "Phenols", "COD")
colnames(rawdata) <- c("Date", "Discharge", parameters, "Source")
rawdata$Date <- as.Date(rawdata$Date, format = "%m/%d/%Y")
write.csv(rawdata, "WWTP-rawdata.csv", row.names = FALSE)

## Clean raw data and save as full data
fulldata <- rawdata

## Replace Phenols recorded as <0.1 with NA
fulldata$Phenols[grep(pattern="<", x=fulldata$Phenols)] <- NA

## Replace "nil" with 0, convert data to numeric
for (i in parameters) {
        fulldata[[i]] <- gsub("nil", x = fulldata[[i]], replacement = 0)
        fulldata[[i]] <- as.numeric(fulldata[[i]])
}

## Save full data
write.csv(fulldata, "WWTP-fulldata.csv", row.names = FALSE)


## Manila bay was reclassifed from Class SC to Class SB
## Company followed Class SB limits starting on April 17, 2015
## For simplification, whole 2Q 2015 was removed from analysis
index.2Q15 <- which(fulldata$Date < as.Date("7/1/2015", format = "%m/%d/%Y"))
Q215 <- fulldata[index.2Q15, ]

## Often when parameters are offspec, effluent is not discharged to Manila bay
## Identify data from instances with No discharge
index.nodis <- which(fulldata$Discharge %in% c("No discharge", "0", "Maintenance S/D"))
Nodis <- fulldata[index.nodis, ]
write.csv(Nodis, "WWTP-Nodischarge.csv", row.names = FALSE)

## Remove No discharge data and Class SC data
clean <- fulldata[!(1:nrow(fulldata) %in% unique(c(index.2Q15,index.nodis))), ]
write.csv(clean, "WWTP-cleandata.csv", row.names = FALSE)

## Add periods for plotting
pd <- as.Date("1/1/2017", format = "%m/%d/%Y") 
cleanpd <- clean %>% mutate(Year = as.factor(year(Date)), Quarter = as.factor(
                paste0(Year, " ", quarter(Date), "Q"))
        ) %>% select(-Discharge)

## Clean Environment
remove(rawdata, fulldata, Q215, Nodis)
remove(index.2Q15, index.nodis, clean)

## Create Clean Plots

## Create "pol" data frame for looped plotting
pol <- data.frame(
        type = parameters,
        hlim = c(30, 50, 5, 9.0, 0.05, 60),
        llim = c(NA, NA, NA, 6.0, NA, NA),
        units = c(rep("mg/L",3), "", rep("mg/L", 2)),
        stringsAsFactors = FALSE)

pos <- as.Date("10/01/2015", format = "%m/%d/%Y")
th <- theme(
        plot.title = element_text(size = 30, face = "bold"),
        plot.subtitle = element_text(size = 18),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        strip.text.x = element_text(face = "bold", size = 20)
        )
ticks <- scale_x_date(breaks = as.Date(c("1/1/2016", "1/1/2017"),
        format = "%m/%d/%Y"), labels = c("2016", 2017))


## 1. Create Scatter Plots for Exploratory Analysis
for (i in 1:6){
        png(paste("Scatter", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Date", y = pol$type[i])) +
                        facet_grid(facets = . ~ Source) + th + ticks +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                                y = paste("Concentration", pol$units[i])) +
                        geom_point(shape = 1, size = 4) +
                        ## High limit
                        geom_point(data = filter_(cleanpd,
                                paste(pol$type[i], ">", pol$hlim[i])),
                                col = "red", alpha = 0.5, size = 4) +
                        geom_hline(yintercept = pol$hlim[i], col = "red") +  
                        geom_text(aes(x = pos, y = pol$hlim[i],
                                label = paste(pol$hlim[i], pol$units[i]),
                                vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_point(data = filter_(cleanpd,
                                paste(pol$type[i], "<", pol$llim[i])),
                                   col = "red", alpha = 0.5, size = 4) +
                        geom_hline(yintercept = pol$llim[i], col = "red") +  
                        geom_text(aes(x = pos, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) + 
                        labs(title = paste("WWTP Effluent", pol$type[i])) 
        })   
        dev.off()
}

## Major noncompliances were observed for TSS and COD on 4th quarter 2016.
## A lot of quarters are missing from Phenols data


## 2. Create box plots per whole Time (~3 years)
## Environmental Performance charts are traditionally submitted as box plots
for (i in 1:6){
        png(paste("BoxT", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Source", y = pol$type[i])) + th +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                             y = paste("Concentration", pol$units[i])) +
                        stat_boxplot(geom ="errorbar", width = 0.1, size = 0.8) +
                        geom_boxplot(fill = "turquoise", outlier.size = 4,
                                outlier.shape = 1) +
                        ## High limit
                        geom_hline(yintercept = pol$hlim[i], col = "red") +
                        geom_text(aes(x = 1.5, y = pol$hlim[i],
                                label = paste(pol$hlim[i], pol$units[i]),
                                vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_hline(yintercept = pol$llim[i], col = "red") +
                        geom_text(aes(x = 1.5, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) +
                        labs(title = paste("WWTP Effluent", pol$type[i]))
        })
        dev.off()
}

## Boxplots for the whole time frame (2015-2017) have whiskers extending beyond 
## the regulatory limits. These boxplots do not show that the company had been 
## fully compliant since the later quarters of 2017.


## 3. Create box plots per year
for (i in 1:6){
        png(paste("BoxY", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Year", y = pol$type[i])) + th +
                        facet_grid(facets = . ~ Source) +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                             y = paste("Concentration", pol$units[i])) +
                        stat_boxplot(geom ="errorbar", width = 0.1, size = 0.8) +
                        geom_boxplot(fill = "turquoise", outlier.size = 4,
                                     outlier.shape = 1) +
                        ## High limit
                        geom_hline(yintercept = pol$hlim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$hlim[i],
                                      label = paste(pol$hlim[i], pol$units[i]),
                                      vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_hline(yintercept = pol$llim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) +
                        labs(title = paste("WWTP Effluent", pol$type[i]))
        })
        dev.off()
}

## Even though the box plots per year already shows the great improvement of the
## company in following regulatory limits by year 2017, it did not show the 
## progressive improvement within 2017 particularly in TSS and Phenols whose 
## 2017 box plots still have whiskers extending beyond the regulatory limits.


## 4. Create box plots per quarter
for (i in 1:6){
        png(paste("BoxQ", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Quarter", y = pol$type[i])) + th +
                        facet_grid(facets = Source ~ .) +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                             y = paste("Concentration", pol$units[i])) +
                        stat_boxplot(geom ="errorbar", width = 0.1, size = 0.8) +
                        geom_boxplot(fill = "turquoise", outlier.size = 4,
                                     outlier.shape = 1) +
                        ## High limit
                        geom_hline(yintercept = pol$hlim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$hlim[i],
                                      label = paste(pol$hlim[i], pol$units[i]),
                                      vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_hline(yintercept = pol$llim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) +
                        labs(title = paste("WWTP Effluent", pol$type[i]))
        })
        dev.off()
}

## Box plots per quarter show improvement from 1Q 2017 to 3Q 2017.
## However, plotting per quarter also emphasizes major noncompliances in TSS and
## COD in 4th quarter 2016, as well as record gaps in Phenols.



## 5. Create box plots per mixed period
## Yearly for 2015 and 2016, quarterly for 2017
## It was noted that this form of summarization skews the x-axis scale and other
## plot types (ie, scatter plot) may be better for showing improvement over time

cleanpd <- mutate(cleanpd, Period = ifelse(Date < pd, levels(Year)[Year],
                levels(Quarter)[Quarter]))

for (i in 1:6){
        png(paste("BoxP", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Period", y = pol$type[i])) + th +
                        facet_grid(facets = . ~ Source) +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                             y = paste("Concentration", pol$units[i])) +
                        stat_boxplot(geom ="errorbar", width = 0.1, size = 0.8) +
                        geom_boxplot(fill = "turquoise", outlier.size = 4,
                                     outlier.shape = 1) +
                        ## High limit
                        geom_hline(yintercept = pol$hlim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$hlim[i],
                                      label = paste(pol$hlim[i], pol$units[i]),
                                      vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_hline(yintercept = pol$llim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) +
                        labs(title = paste("WWTP Effluent", pol$type[i]))
        })
        dev.off()
}

## Almost all of the box plots now have whiskers below Class SB limits.
## The medians are also progressing downwards from 1Q to 3Q 2017.
## However, there are blatant outliers for TSS and COD that are skewing plots.
## Adjusting the plot y-axis limit will allow for better plot aesthetics.


## 6. Create bound period box plots

pol$ylimh <- c(45, 80, 5, 10, 0.12, 120)
pol$yliml <- c(0, 0, 0, 4, 0, 0)

for (i in 1:6){
        png(paste("BoundBoxP", pol$type[i], ".png"), width = 640, height = 480) 
        print({
                ggplot(cleanpd, aes_string(x = "Period", y = pol$type[i])) + th +
                        facet_grid(facets = . ~ Source) +
                        coord_cartesian(ylim = c(pol$yliml[i], pol$ylimh[i])) +
                        labs(subtitle = "3Q 2015 - 3Q 2017",
                             y = paste("Concentration", pol$units[i])) +
                        stat_boxplot(geom ="errorbar", width = 0.1, size = 0.8) +
                        geom_boxplot(fill = "turquoise", outlier.size = 4,
                                     outlier.shape = 1) +
                        ## High limit
                        geom_hline(yintercept = pol$hlim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$hlim[i],
                                      label = paste(pol$hlim[i], pol$units[i]),
                                      vjust = -0.5), size = 5) +
                        ## Low limit
                        geom_hline(yintercept = pol$llim[i], col = "red") +
                        geom_text(aes(x = 2, y = pol$llim[i],
                                      label = paste(pol$llim[i], pol$units[i]),
                                      vjust = 1.5), size = 5) +
                        labs(title = paste("WWTP Effluent", pol$type[i]))
        })
        dev.off()
}

## These are the only plots that management found acceptable, amidst caution that 
## the x-axis scale was skewed by the mixed period groupings.
