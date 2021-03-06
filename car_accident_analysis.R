library(tidyverse)
library(lubridate)
library(RSocrata)
library(skimr)



# custom theme
theme_jacob <- function(..., base_size = 11) {
  theme(panel.grid.minor = element_blank(),
        panel.grid.major =  element_line(color = "#d0d0d0"),
        panel.background = element_rect(fill = "#f0f0f0", color = NA),
        plot.background = element_rect(fill = "#f0f0f0", color = NA),
        legend.background = element_rect(fill = '#f0f0f0', color = NA),
        legend.position = 'top',
        panel.border = element_blank(),
        strip.background = element_blank(),
        plot.margin = margin(0.5, 1, 0.5, 1, unit = "cm"),
        axis.ticks = element_blank(),
        text = element_text(family = "Gill Sans MT", size = base_size),
        axis.text = element_text(face = "bold", color = "grey40", size = base_size),
        axis.title = element_text(face = "bold", size = rel(1.2)),
        axis.title.x = element_text(margin = margin(0.5, 0, 0, 0, unit = "cm")),
        axis.title.y = element_text(margin = margin(0, 0.5, 0, 0, unit = "cm"), angle = 90),
        plot.title = element_text(face = "bold", size = rel(1.05), hjust = 0.5),
        plot.title.position = "plot",
        plot.subtitle = element_text(size = 11, margin = margin(0.2, 0, 0, 0, unit = "cm"), hjust = 0.5),
        plot.caption = element_text(size = 10, margin = margin(1, 0, 0, 0, unit = "cm"), hjust = 1),
        strip.text = element_text(size = rel(1.05), face = "bold"),
        ...
  )
}

years_ago <- today() - years(2)
crash_url <- glue::glue("https://data.cityofchicago.org/Transportation/Traffic-Crashes-Crashes/85ca-t3if?$where=CRASH_DATE > '{years_ago}'")
crash_raw <- as_tibble(read.socrata(crash_url))

# skim(crash_raw)

crash <- crash_raw %>%
  transmute(injuries = if_else(injuries_total > 0, "Injuries", "No Injuries"),
            crash_date, crash_hour,
            report_type = if_else(report_type == "", "UNKNOWN", report_type),
            num_units, posted_speed_limit, weather_condition, lighting_condition, roadway_surface_cond, first_crash_type, trafficway_type,
            prim_contributory_cause, latitude, longitude, crash_month) %>%
  na.omit()

# time series plot
crash %>%
  mutate(crash_date = floor_date(crash_date, unit = 'week')) %>%
  count(crash_date, injuries) %>%
  filter(crash_date != last(crash_date),
         crash_date != first(crash_date)) %>%
  ggplot(aes(crash_date, n, color = injuries)) +
  geom_line(size = 1.5, alpha = 0.6) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(x = 'Accident Date',
       y = 'Number of Accidents',
       title = 'Weekly Time Series of Car Accidents in Chicago',
       color = NULL) +
  theme_light() +
  theme(legend.position = 'top')
ggsave("crashtimeseries.png", width = 9, height = 4)

# injury % over time plot
crash %>%
  mutate(crash_date = floor_date(crash_date, unit = 'week')) %>%
  count(crash_date, injuries) %>%
  filter(crash_date != last(crash_date),
         crash_date != first(crash_date)) %>%
  group_by(crash_date) %>%
  mutate(percent_injury = n / sum(n)) %>%
  ungroup() %>%
  filter(injuries == 'Injuries') %>%
  ggplot(aes(crash_date, percent_injury)) +
  geom_line(size = 1.5, alpha = 0.6) +
  geom_smooth() +
  scale_y_continuous(limits = c(0, NA), labels = scales::percent_format()) +
  labs(x = 'Accident Date',
       y = '% Chance of an Injury',
       title = 'Is the % Chance of Car Accident Injuries changing over time?') +
  theme_light()
ggsave('crashinjurypercent.png', width = 9, height = 4)

wday_crash <- crash %>%
  mutate(crash_date = wday(crash_date, label = TRUE)) %>%
  count(crash_date, injuries) %>%
  group_by(injuries) %>%
  mutate(percent = n / sum(n),
         week_type = case_when(crash_date %in% c('Fri', 'Sat', 'Sun') ~ 'Weekend',
                               TRUE ~ 'Weekday')) %>%
  ungroup() %>%
  group_by(week_type) %>%
  mutate(percent_wday_inj = mean(percent),
         colr = case_when(percent_wday_inj > .14 ~ 'Red', 
                          TRUE ~ 'blue')) %>%
  ungroup()

# weekly plot, .7% more likely for injury on weekend (Fri, Sat, Sun) than weekdays.  noticeable.
wday_crash %>%
  ggplot(aes(percent, crash_date, fill = injuries)) +
  geom_col(position = 'dodge') +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(x = '% of Total (Grouped by Injury)',
       y = NULL,
       title = 'Does Day of the Week Affect Probability of Injuries from Car Accidents?',
       fill = NULL) +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashinjurywday.png', width = 9, height = 4)

monthly_crash <- crash %>%
  select(crash_month, injuries) %>%
  group_by(crash_month, injuries) %>%
  count() %>%
  ungroup() %>%
  group_by(crash_month) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3),
         tot_crashes = sum(n),
         real_month = case_when(crash_month == 1 ~ 'Jan',
                                crash_month == 2 ~ 'Feb',
                                crash_month == 3 ~ 'Mar',
                                crash_month == 4 ~ 'Apr',
                                crash_month == 5 ~ 'May',
                                crash_month == 6 ~ 'Jun',
                                crash_month == 7 ~ 'Jul',
                                crash_month == 8 ~ 'Aug',
                                crash_month == 9 ~ 'Sep',
                                crash_month == 10 ~ 'Oct',
                                crash_month == 11 ~ 'Nov',
                                TRUE ~ 'Dec')) %>%
  ungroup() %>%
  mutate(real_month = fct_reorder(real_month, crash_month))

# monthly plot
monthly_crash %>%
  ggplot(aes(pct_total, real_month, fill = injuries, label = scales::percent(pct_total, accuracy = .1))) +
  geom_col(position = position_dodge(width = .75)) +
  geom_text(position = position_dodge(width = .75), hjust = -0.11, size = 3.5) +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(x = '% of Total (Grouped by Month)',
       y = NULL,
       title = 'Which Months are Injuries from Car Accidents more likely to occur ?',
       fill = NULL) +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashmonthly.png', width = 9, height = 4)

crash %>%
  count(first_crash_type, injuries) %>%
  mutate(first_crash_type = fct_reorder(first_crash_type, n)) %>%
  group_by(injuries) %>%
  mutate(percent = n / sum(n)) %>%
  ungroup() %>%
  group_by(first_crash_type) %>%
  filter(sum(n) > 10000) %>%
  ungroup() %>%
  ggplot(aes(percent, first_crash_type, fill = injuries)) +
  geom_col(position = 'dodge', alpha = 0.99) +
  scale_x_continuous(labels = scales::percent_format()) +
  theme_light()

crash %>%
  filter(latitude > 0) %>%
  ggplot(aes(longitude, latitude, color = injuries)) +
  geom_point(size = 0.5, alpha = 0.3) +
  labs(color = NULL) +
  scale_color_manual(values = c('red', 'gray80')) +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashlatlong.png', width = 12, height = 6)


crashes_by_hr <- crash_raw %>%
  select(crash_hour) %>%
  group_by(crash_hour) %>%
  count() %>%
  mutate(text = case_when(crash_hour <= 12 ~ 'AM', 
                          TRUE ~ 'PM'),
         new_hr = case_when(crash_hour > 12 ~ (crash_hour - 12),
                            crash_hour <= 12 & crash_hour > 0 ~ as.numeric(crash_hour),
                            TRUE ~ 0),
         final_hr = paste0(new_hr, ' ', text),
         final_hr = replace(final_hr, final_hr == '0 AM', 'Midnight'),
         final_hr = replace(final_hr, final_hr == '12 AM', 'Noon'),
         final_hr = fct_reorder(final_hr, crash_hour)) %>%
  arrange(crash_hour)

# plot 1
crashes_by_hr %>%
  ggplot(aes(n, final_hr)) +
  geom_col() +
  geom_vline(aes(xintercept = mean(n))) +
  annotate('text', x = 9800, y = 2, label = 'Average') +
  labs(x = 'Number of Accidents',
       y = NULL,
       title = 'When are Car Accidents Most Likely to Happen throughout a day ?') +
  theme_light()
ggsave('crashnormalhr.png', width = 9, height = 4)

crash_types <- crash %>%
  select(first_crash_type, injuries) %>%
  group_by(first_crash_type, injuries) %>%
  count() %>%
  ungroup() %>%
  group_by(first_crash_type) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3),
         tot_crashes = sum(n)) %>%
  ungroup() %>%
  mutate(first_crash_type = fct_reorder(first_crash_type, tot_crashes)) %>%
  filter(tot_crashes >= 10000)

crash_types %>%
  ggplot(aes(n, first_crash_type, fill = injuries, label = scales::percent(pct_total))) +
  geom_col(position = 'dodge') +
  geom_text(data = dd %>% filter(injuries == 'injuries'), aes(pct_total), hjust = -.3, vjust = 2)
  
weather_type_var <- crash %>%
  select(weather_condition, injuries) %>%
  group_by(weather_condition, injuries) %>%
  count() %>%
  filter(n > 32,
         weather_condition != 'BLOWING SNOW') %>%
  ungroup() %>%
  group_by(weather_condition) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3)) %>%
  ungroup() %>%
  filter(injuries == 'Injuries') %>%
  rename(pct_total2 = pct_total) %>%
  select(weather_condition, pct_total2)


weather_type <- crash %>%
  select(weather_condition, injuries) %>%
  group_by(weather_condition, injuries) %>%
  count() %>%
  filter(n > 32,
         weather_condition != 'BLOWING SNOW') %>%
  ungroup() %>%
  group_by(weather_condition) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3)) %>%
  ungroup() %>%
  left_join(weather_type_var) %>%
  mutate(weather_condition = fct_reorder(weather_condition, pct_total2))


weather_type %>%
  ggplot(aes(pct_total, weather_condition, fill = injuries, label = scales::percent(pct_total, accuracy = 0.1))) +
  geom_col(position = position_dodge(width = .75)) +
  geom_text(position = position_dodge(width = .75), hjust = -0.11, size = 3.5) +
  labs(x = '% of Total (Grouped by Weather Condition)',
       y = NULL,
       fill = NULL,
       title = 'Do certain Weather Conditions lead to a higher probability of Injury in Car Accidents?') +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashweather.png', width = 15, height = 8)


ggplot(aes(n, lighting_condition, fill = injuries, label = scales::percent(pct_total, accuracy = 0.1))) +
  geom_col(position = position_dodge(width = .75)) +
  geom_text(position = position_dodge(width = .75), hjust = -0.11, size = 3) +
  

daynight_type <- crash %>%
  select(lighting_condition, injuries) %>%
  group_by(lighting_condition, injuries) %>%
  count() %>%
  ungroup() %>%
  group_by(lighting_condition) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3),
         tot_crashes = sum(n)) %>%
  ungroup() %>%
  mutate(lighting_condition = fct_reorder(lighting_condition, tot_crashes))

daynight_type %>%
  ggplot(aes(n, lighting_condition, fill = injuries, label = scales::percent(pct_total, accuracy = 0.1))) +
  geom_col(position = position_dodge(width = .75)) +
  geom_text(position = position_dodge(width = .75), hjust = -0.11, size = 3) +
  scale_x_continuous(limits = c(0, 125000)) +
  labs(x = 'Number of Accidents',
       y = NULL,
       title = 'Do Light Conditions Affect Probability of Injuries from Car Accidents ?',
       fill = NULL) +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashlightcond.png', width = 9, height = 4)

cause_crash <- crash %>%
  select(injuries, prim_contributory_cause) %>%
  group_by(injuries, prim_contributory_cause) %>%
  count() %>%
  ungroup() %>%
  group_by(prim_contributory_cause) %>%
  mutate(pct_total = n / sum(n),
         pct_total = round(pct_total, 3),
         tot_crashes = sum(n),
         prim_contributory_cause = fct_reorder(prim_contributory_cause, tot_crashes)) %>%
  ungroup()



alcohol_only <- crash %>%
  filter(prim_contributory_cause == 'UNDER THE INFLUENCE OF ALCOHOL/DRUGS (USE WHEN ARREST IS EFFECTED)')


crashes_by_hr_alc <- alcohol_only %>%
  select(crash_hour) %>%
  group_by(crash_hour) %>%
  count() %>%
  mutate(text = case_when(crash_hour <= 12 ~ 'AM', 
                          TRUE ~ 'PM'),
         new_hr = case_when(crash_hour > 12 ~ (crash_hour - 12),
                            crash_hour <= 12 & crash_hour > 0 ~ as.numeric(crash_hour),
                            TRUE ~ 0),
         final_hr = paste0(new_hr, ' ', text),
         final_hr = replace(final_hr, final_hr == '0 AM', 'Midnight'),
         final_hr = replace(final_hr, final_hr == '12 AM', 'Noon'),
         final_hr = fct_reorder(final_hr, crash_hour)) %>%
  arrange(crash_hour)

# Alcohol plot.
crashes_by_hr_alc %>%
  ggplot(aes(n, final_hr)) +
  geom_col() +
  geom_vline(aes(xintercept = mean(n))) +
  labs(x = 'Number of Accidents',
       y = NULL,
       title = 'When are Alcohol-related Car Accidents Likely to Happen throughout a day ?') +
  theme_light()
ggsave('crashhralc.png', width = 9, height = 4)


prim_cause_2 <- crash %>%
  select(prim_contributory_cause, injuries) %>%
  group_by(prim_contributory_cause, injuries) %>%
  count() %>%
  ungroup() %>%
  group_by(prim_contributory_cause) %>%
  mutate(pct_total = n / sum(n),
         tot_crashes = sum(n),
         prim_contributory_cause = fct_reorder(prim_contributory_cause, pct_total)) %>%
  ungroup() %>%
  filter(tot_crashes >= 500) %>%
  filter(injuries == 'Injuries') %>%
  mutate(pct_total2 = pct_total) %>%
  select(prim_contributory_cause, pct_total2)


prim_cause <- crash %>%
  select(prim_contributory_cause, injuries) %>%
  group_by(prim_contributory_cause, injuries) %>%
  count() %>%
  ungroup() %>%
  group_by(prim_contributory_cause) %>%
  mutate(pct_total = n / sum(n),
         tot_crashes = sum(n)) %>%
  ungroup() %>%
  filter(tot_crashes >= 500) %>%
  left_join(prim_cause_2) %>%
  mutate(prim_contributory_cause = fct_reorder(prim_contributory_cause, pct_total2))

prim_cause %>%
  ggplot(aes(pct_total, prim_contributory_cause, fill = injuries, label = scales::percent(pct_total, accuracy = 0.1))) +
  geom_col(position = position_dodge(width = .75)) +
  geom_text(position = position_dodge(width = .75), hjust = -0.11, size = 3.5) +
  geom_col(position = position_dodge(width = .75)) +
  labs(x = '% of Total (Grouped by Cause)',
       y = NULL,
       fill = NULL,
       title = 'Do Specific Car Accident Causes lead to a higher probability of Injuries?') +
  theme_light() +
  theme(legend.position = 'top')
ggsave('crashprimcause.png', width = 15, height = 8)
