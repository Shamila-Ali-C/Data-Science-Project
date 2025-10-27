#-------------------------REGRESSION MODEL BUILDING-----------------------------

# Loading library
library(caret)

# Checking data
head(data)
summary(data)
tail(data)

#--------------------------------MODEL BUILDING---------------------------------

# Removing irrelevant column
data_model = data %>% 
  select(-ORDERNUMBER )

data_model

# Defining train test data
set.seed(123)

trainIndex=createDataPartition(data_model$SALES, p = 0.8, list = FALSE) 
train_data=data_model[trainIndex, ] 
test_data=data_model[-trainIndex, ] 
train_control=trainControl( 
  method = "cv",         
  number = 5,            
  verboseIter = TRUE 
)

# Initializing the linear regression model
set.seed(123)

lm_model = train( 
  SALES ~ .,  
  data = train_data, 
  method = "lm", 
  preProcess = c("center", "scale", "zv", "nzv"), 
  trControl = train_control 
) 

# Printing the model
print(lm_model)

#---------------------------------PREDICTION------------------------------------

pred_lm <- predict(lm_model, newdata = test_data)
postResample(pred = pred_lm, obs = test_data$SalePrice)

print(pred_lm)
