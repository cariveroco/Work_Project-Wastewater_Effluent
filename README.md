## Waste Water Effluent Pollutant Levels for Regulatory Compliance

The company was preparing an Environmental Performance Report which aimed to show whether the company adhered to environmental regulations for the past years. This project focused on exploring and producing the best visual representation of the pollutant readings from the effluent of the company’s two wastewater treatment plants, WWTP-1 and WWTP-2, which are being discharged to Manila bay. 

Traditionally, environmental performance reports are submitted as box plots. The script first analyzed the data using scatter plots, then explored box plots using various grouping of data (ie, per whole time range, per year, per quarter). The best plots which emphasized the company’s progressive improvement in 2017 while still showing noncompliances in previous years were achieved when data were plotted per year in 2015 and 2016, while per quarter in 2017. These mixed-period plots were proposed to management and were the only ones they found acceptable for publication.

## Data Scope and Cleaning

Measurements for the regulated parameters are recorded daily. The source used in compiling the data are from PDF files of self-monitoring reports submitted to DENR, from 2nd quarter 2015 to 3rd quarter 2017. The company ceased in submitting daily data since 4th quarter 2017.

Most of the code used to compile data from PDF files to the *Input* csv files were not included anymore in the published script as they were generated rapidly and without a clean structure. Cleaning of *NA values* as well as *non-exact data* (ie, <1 mg/L) were included in the script.

DENR reclassified Manila bay from Class SC to Class SB, which meant that effluent discharge limits had become more stringent. On April 17, 2015, the company fully complied to following Class SB limits. Thus, data for *2nd Quarter 2015* which used both Class SB and SC limits were removed to simplify the analysis.

Normally, if one or more of the measured parameters are off-spec, the plant will not discharge effluent to water bodies and instead will initiate reprocessing. Such days tagged as *No Discharge* were removed from the analysis since no violations were committed.

## Parameters

The regulated parameters are Biological Oxygen Demand (BOD), Total Suspended Solids (TSS), Oil & Grease (OG), pH, Phenols, and Chemical Oxygen Demand (COD). Records are all in units of mg/L concentration, except for pH which is unitless. The following data were used for looping a single plotting code for all 6 parameters:

Parameter | Class SB Limits
-------------- | ----------------------
BOD            | 30 mg/L
TSS              |50 mg/L
OG              |5 mg/L
pH               | 6.0 – 9.0
Phenols      | 0.05 mg/L
COD            | 60 mg/L

## Analysis Process

1. **Scatter Plots for Exploratory Analysis**

Major noncompliances were observed for TSS and COD on 4th quarter 2016. Also, a lot of quarters are missing from Phenols data.

2. **Box Plots for whole Time frame**

Environmental performance charts are traditionally submitted as box plots. When a single box plot per wastewater plant was plotted for the whole range of data, some plots have whiskers extending beyond the regulatory limits. These plots do not show that the company had been fully compliant since the last quarters of 2017.

3. **Box Plots per Year**

Even though box plots plotted per year already shows the great improvement of the company in following regulatory limits by year 2017, it did not show the progressive improvement within 2017 particularly in TSS and Phenols whose 2017 box plots still have whiskers extending beyond the regulatory limits.

4. **Box Plots per Quarter**

Plots per quarter show improvement from 1Q 2017 to 3Q 2017. However, plotting per quarter also emphasizes major noncompliances in TSS and COD in 4th quarter 2016, as well as record gaps in Phenols.

5. **Box Plots per mixed Period**

When data are plotted yearly in 2015 & 201 and quarterly in 2017, almost all of the box plots now have whiskers below Class SB limits. The medians are also progressing downwards from 1Q to 3Q 2017. However, there are blatant outliers for TSS and COD that are skewing plots. Adjusting the plot y-axis limit will allow for better plot aesthetics.


6. **Box Plots per Period with Bound axis (FINAL)**

The following axis limits were applied to the box plots to remove emphasis on outlier data:

Parameter | Y-Axis Limits
-------------- | ----------------------
BOD            | 0 to 45
TSS              |0 to 80
OG              |0 to 5
pH               | 4 to 10
Phenols      | 0 to 0.12
COD            | 0 to 120

These are the final plots proposed to management and which they found acceptable for publication.

