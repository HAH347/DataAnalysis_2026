#--------------------start-------------------------------
# Get current working directory
getwd()

# 你的文件路径（已修正格式）
data_path <- "C:/Users/ASUS/Downloads/DataSet_No_Details.csv"

#----------------read dataset--------------------------
df <- read.csv(data_path)
str(df)

# Beautiful summary with histograms for numeric variables
if (!require("skimr")) install.packages("skimr")
library(skimr)
skim(df) 

#---------------data set preparation------------------
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

# Delete a few columns 
cols_to_remove <- c("h_index_34", "h_index_56", "hormone10_1", "hormone10_2","an_index_23","outcome","factor_eth","factor_h","factor_pcos","factor_prl")
MD_df <- df %>% select(-any_of(cols_to_remove))
factor_df <- df %>% select (record_id, outcome, factor_eth, factor_h,factor_pcos,factor_prl)
str(MD_df)
summary(factor_df)

#--------------Identify Missing Values-----------------
sum(is.na(MD_df))               
colSums(is.na(MD_df))          
skim(MD_df)

na_stats <- colMeans(is.na(MD_df)) * 100 
na_stats

na_stats_filtered <- na_stats[na_stats <= 35] 
data.frame(
  Column = names(na_stats_filtered),
  NA_Percent = na_stats_filtered,
  row.names = NULL
)

na_stats_filtered_1 <- na_stats[na_stats > 35] 
data.frame(
  Column = names(na_stats_filtered_1),
  NA_Percent = na_stats_filtered_1,
  row.names = NULL
)

#-------------------Visualizing Missing Data Patterns------------------
# 修复：统一安装 + 加载，不会报错
if (!require("visdat")) install.packages("visdat")
library(visdat)
vis_miss(MD_df)  

if (!require("naniar")) install.packages("naniar")
library(naniar)
gg_miss_var(MD_df)  

#------------------ Analyzing the Impact of Missing Data--------------
cols_to_remove1 <- c("hormone9", "hormone11", "hormone12", "hormone13","hormone14")
handle_MD_df <- MD_df %>% select(-any_of(cols_to_remove1))
str(handle_MD_df)

#------------------Little's MCAR Test（已补上）----------------------
if (!require("naniar")) install.packages("naniar")
if (!require("mice")) install.packages("mice")
library(naniar)
library(mice)

# 运行 MCAR 检验
mcar_test <- mcar_test(handle_MD_df)
print("=== Little's MCAR Test 结果 ===")
print(mcar_test)

#------------------Imputation with MICE-------------------------------
if (!require("mice")) install.packages("mice")
if (!require("ggplot2")) install.packages("ggplot2")
library(mice)
library(ggplot2)

# ==========================================
# 方法1：随机森林 RF 填充（修复变量错误）
# ==========================================
set.seed(123)
imp_rf <- mice(handle_MD_df, method = "rf", m = 5, print = FALSE)  
final_rf <- complete(imp_rf)  

# 密度图
ggplot(handle_MD_df, aes(x=hormone10_generated, fill="Original")) +
  geom_density(alpha=0.5) +
  geom_density(data=final_rf, aes(x=hormone10_generated, fill="RF Imputed"), alpha=0.5) +
  labs(title="Density Plot: Original vs RF Imputed") +
  scale_x_continuous(limits = c(0, 2))

# ==========================================
# 方法2：PMM 填充（修复变量错误）
# ==========================================
set.seed(123)
imp_pmm <- mice(handle_MD_df, method = "pmm", m = 5, print = FALSE)  
final_pmm <- complete(imp_pmm)  

# 密度图
ggplot(handle_MD_df, aes(x=hormone10_generated, fill="Original")) +
  geom_density(alpha=0.5) +
  geom_density(data=final_pmm, aes(x=hormone10_generated, fill="PMM Imputed"), alpha=0.5) +
  labs(title="Density Plot: Original vs PMM Imputed") +
  scale_x_continuous(limits = c(0, 2))

#----------------Outlier Detection------------------------
if (!require("tidyr")) install.packages("tidyr")
library(tidyr)

# 使用 RF 结果画箱线图
outliers_data <- final_rf %>%
  select(lipids1, lipids2, lipids3, lipids4, lipids5) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value")

ggplot(outliers_data, aes(x = variable, y = value)) +
  geom_boxplot(fill = "lightblue", alpha = 0.7) +
  labs(title = "Outlier Detection", x = "variables", y = "value") +
  theme_minimal()

# 全变量箱线图
final_rf %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything()) %>%
  ggplot(aes(y = value)) +
  geom_boxplot() +
  facet_wrap(~name, scales = "free") +
  labs(title = "Boxplots for Outlier Detection")

