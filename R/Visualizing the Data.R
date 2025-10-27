#----------------------------------VISUALIZATION--------------------------------

# Loading library
library(ggplot2)

# Checking the data
head(data)
tail(data)
str(data)
summary(data)

#--------------------EXPLORATORY DATA ANALYSIS (EDA)----------------------------

# Total Sales by Year
ggplot(data, aes(x=factor(YEAR_ID), y=SALES, fill=factor(YEAR_ID))) +
  geom_bar(stat="summary", fun="sum") +
  labs(title="Total Sales by Year", x="Year", y="Total Sales") +
  theme_bw()

# Sales by Quarter
ggplot(data, aes(x=factor(QTR_ID), y=SALES, fill=factor(YEAR_ID))) +
  geom_bar(stat="summary", fun="sum", position="dodge") +
  labs(title="Quarterly Sales by Year", x="Quarter", y="Sales") +
  theme_bw()

# Sales by Country
ggplot(data, aes(x=reorder(COUNTRY, SALES, sum), y=SALES)) +
  geom_bar(stat="summary", fun="sum", fill="skyblue") +
  coord_flip() +
  labs(title="Sales by Country", x="Country", y="Total Sales") +
  theme_bw()

# Sales by Deal Size
ggplot(data, aes(x=DEALSIZE, y=SALES, fill=DEALSIZE)) +
  geom_boxplot() +
  labs(title="Sales Distribution by Deal Size", x="Deal Size", y="Sales") +
  theme_bw()

#---------------------------------TIME SERIES-----------------------------------

# Create Monthly Sales Data
monthly_sales <- data %>%
  group_by(YEAR_ID, MONTH_ID) %>%
  summarise(total_sales = sum(SALES))

# Convert to Date
monthly_sales$date <- as.Date(paste(monthly_sales$YEAR_ID, monthly_sales$MONTH_ID, 1, sep="-"))

# Plot Monthly Sales
ggplot(monthly_sales, aes(x=date, y=total_sales)) +
  geom_line(color="darkblue") +
  labs(title="Monthly Sales Trend", x="Date", y="Sales") +
  theme_bw()

#--------------------------CUSTOMER & PRODUCT INSIGHTS--------------------------

# Top 10 Customers
top_customers <- data %>%
  group_by(CUSTOMERNAME) %>%
  summarise(total_sales = sum(SALES)) %>% 
  arrange(desc(total_sales)) %>%
  head(10)

ggplot(top_customers, aes(x=reorder(CUSTOMERNAME, total_sales), y=total_sales)) +
  geom_col(fill="tomato") +
  coord_flip() +
  labs(title="Top 10 Customers by Sales", x="Customer", y="Total Sales")

# Top Product Lines
ggplot(data, aes(x=PRODUCTLINE, y=SALES, fill=PRODUCTLINE)) +
  geom_bar(stat="summary", fun="sum") +
  labs(title="Sales by Product Line", x="Product Line", y="Total Sales") +
  theme_bw()

