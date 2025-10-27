#----------------------------------DATA LOADING-------------------------------------

# Loading library
library(dplyr)

# Loading dataset
data <- read.csv("sales_data_sample.csv",stringsAsFactors = FALSE)
data

# Preview
str(data)
summary(data)
head(data)
tail(data)

# Checking the datatype of each column in the dataset
sapply(data,class)

# Convert ORDERDATE to proper Date format
data$ORDERDATE <- as.Date(data$ORDERDATE, format="%m/%d/%Y")
data$Year <- format(data$ORDERDATE, "%Y")
data$Month <- format(data$ORDERDATE, "%m")
data$Quarter <- paste0("Q", ceiling(as.numeric(data$Month)/3))

data

#----------------------------------DAT CLEANING------------------------------------

## MISSING VALUE DETECTION ##

# Checking the sum of missing values
anyNA(data)
sum(is.na(data))

# Checking which column contain the null values
missing_values <- colSums(is.na(data))
missing_values[missing_values > 0]

# Checking the data type of the column TERRITORY
class(data$TERRITORY)

# Filling the null values
data$TERRITORY = as.character(data$TERRITORY)
data$TERRITORY[is.na(data$TERRITORY)] = "None"
data$TERRITORY = as.factor(data$TERRITORY)

# Checking whether fill or not
sum(is.na(data))

## OUTLIER TREATMENT ##

# Plotting box plot for checking outliers
for(col in names(data)){
  if(is.numeric(data[[col]])){
    boxplot(data[[col]],
            main = paste("Boxplot of",col),
            ylab = col,
            col = "lightblue")
  }
}

# Capping the outliers using IQR method
for(col in names(data)){
  if(is.numeric(data[[col]])){
    Q1 <- quantile(data[[col]], 0.25) 
    Q3 <- quantile(data[[col]], 0.75) 
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 1.5*IQR 
    upper_bound <- Q3 + 1.5*IQR
    data[[col]] <- ifelse(data[[col]] < lower_bound, lower_bound, 
                          ifelse(data[[col]] > upper_bound, upper_bound, 
                                 data[[col]]))
  }
}


# Checking whether it capped or not
for(col in names(data)){
  if(is.numeric(data[[col]])){
    boxplot(data[[col]],
            main = paste("Boxplot of",col),
            ylab = col,
            col = "lightblue")
  }
}

#---------------------------FILTERING & GROUP BY--------------------------------

# Total Sales (Overall)
data %>%
  summarise(total_sales = sum(SALES, na.rm = TRUE))

# Total Sales for a Specific Year
data %>%
  filter(Year == "2003") %>%
  summarise(total_sales_2003 = sum(SALES, na.rm = TRUE))

# Total Sales by Year
data %>%
  group_by(Year) %>%
  summarise(total_sales = sum(SALES, na.rm = TRUE))

# Sales for USA Only
data %>%
  filter(COUNTRY == "USA") %>%
  summarise(total_sales_usa = sum(SALES, na.rm = TRUE))

# Top Product Line in 2004
data %>%
  filter(Year == "2004") %>%
  group_by(PRODUCTLINE) %>%
  summarise(total_sales = sum(SALES, na.rm = TRUE)) %>%
  arrange(desc(total_sales)) %>%
  head(1)
