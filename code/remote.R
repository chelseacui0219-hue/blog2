# ============================================================
# Data Source 3: RemoteOK (JSON API)
# Analyze skill tags in remote tech job postings
# ============================================================
library(tidyverse)   # dplyr, tibble, stringr, purrr, ggplot2, readr
library(httr2)       # request, req_perform
library(jsonlite)    # fromJSON
library(here)        # here()

# ============================================================

resp <- request("https://remoteok.com/api") |>
  req_user_agent("Mozilla/5.0 (R scraping demo)") |>
  req_perform()

resp_status(resp) 

# ============================================================

json_text <- resp_body_string(resp)
raw_data <- fromJSON(json_text)

dim(raw_data)   
names(raw_data)

remoteok_raw <- raw_data |>
  as_tibble() |>
  select(position, company, location, date, tags, salary_min, salary_max, url) |>
  filter(!is.na(position)) |>
  mutate(tags = map(tags, ~ as.character(unlist(.x))))

glimpse(remoteok_raw)

dir.create(here("data", "raw"), recursive = TRUE, showWarnings = FALSE)
write_csv(remoteok_raw, here("data", "raw", "remoteok_jobs_raw.csv"))

# ============================================================

tags_long <- remoteok_raw |>
  select(position, company, tags) |>
  unnest(tags) |>
  filter(!is.na(tags), tags != "")

tag_counts <- tags_long |>
  count(tags, sort = TRUE)

# 筛选技术类技能
tech_skills <- c(
  "golang", "sys admin", "testing", "cloud",
  "excel", "infosec", "microsoft", "saas",
  "web dev", "c", "mobile", "stats",
  "embedded", "api", "backend", "game dev",
  "python", "data science", "salesforce"
)

remoteok_skill_counts <- tag_counts |>
  filter(tags %in% tech_skills) |>
  arrange(desc(n))

print(remoteok_skill_counts, n = Inf)

dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write_csv(remoteok_skill_counts, here("data", "clean", "remoteok_skills_clean.csv"))

# ============================================================

p_remoteok <- remoteok_skill_counts |>
  mutate(tags = reorder(tags, n)) |>
  ggplot(aes(x = n, y = tags)) +
  geom_col(fill = "#5b9e5b") +
  geom_text(aes(label = n), hjust = -0.3, size = 3.5) +
  labs(
    title = "Most In-Demand Technical Skills on RemoteOK",
    subtitle = "Based on 99 remote job postings",
    x = "Number of postings mentioning this skill",
    y = NULL,
    caption = "Data source: RemoteOK (https://remoteok.com)"
  ) +
  theme_minimal(base_size = 13) +
  expand_limits(x = max(remoteok_skill_counts$n) * 1.2)

p_remoteok


dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)
ggsave(
  here("output", "remoteok_skills.png"),
  plot = p_remoteok,
  width = 8,
  height = 6,
  dpi = 300
)

