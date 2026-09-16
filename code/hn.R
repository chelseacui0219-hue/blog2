# ============================================================
# Data Source 1: HN we are hiring (RSS)
# Analyze skill demand in remote tech job postings
# ============================================================
library(rvest)
library(dplyr)
library(tibble)
library(stringr)
library(purrr)
library(ggplot2)
library(tidyverse)
library(here)

url <- "https://news.ycombinator.com/item?id=49522897"
page <- read_html(url)

comments <- page %>% html_elements(".commtext")
hn_texts <- comments %>% html_text2()

length(hn_texts)

hn_jobs <- tibble(
  text = hn_texts
)

hn_jobs
write_csv(hn_jobs, here("data", "raw", "hn_jobs_raw.csv"))

#The hn_jobs include the comment from the employees, so it should be clean

hn_jobs_clean <- hn_jobs |>
  filter(
    # 招聘帖通常包含 | 分隔符，且长度 > 100 字符
    str_detect(text, "\\|"),
    nchar(text) > 100
  )

nrow(hn_jobs_clean)  

print(hn_jobs_clean, n = 247)
#There are still two lines that are comments, delete them 
hn_jobs_clean <- hn_jobs_clean |>
  filter(
    !str_detect(text, "^Location:"),           # 过滤 "Who wants to be hired" 帖
    !str_detect(text, "^I think it suffers")   # 过滤讨论帖
  )

nrow(hn_jobs_clean) 
write_csv(hn_jobs_clean, here("data", "clean", "hn_jobs_clean.csv"))

skills_list <- c(
  "Python", "JavaScript", "TypeScript", "Java", "Golang",
  "React", "Vue", "Angular", "Node", "Django", "Flask",
  "SQL", "PostgreSQL", "MySQL", "MongoDB",
  "AWS", "Azure", "GCP", "Docker", "Kubernetes",
  "Git", "CI/CD", "GraphQL",
  "Machine Learning", "TensorFlow", "PyTorch",
  "HTML", "CSS", "Linux", "Bash", "Rust"
)

hn_skill_counts <- tibble(
  skill = skills_list,
  n = map_int(skills_list, function(s) {
    sum(str_detect(hn_jobs_clean$text, regex(paste0("\\b", s, "\\b"), ignore_case = TRUE)))
  })
) |>
  filter(n > 0) |>
  arrange(desc(n))

print(hn_skill_counts, n = Inf)

hn_skills <- hn_skill_counts |>
  mutate(skill = reorder(skill, n)) |>
  ggplot(aes(x = n, y = skill)) +
  geom_col(fill = "#e07b39") +
  geom_text(aes(label = n), hjust = -0.3, size = 3.5) +
  labs(
    title = "Most In-Demand Skills in Hacker News Job Postings",
    subtitle = "Based on 245 comments from Ask HN: Who is hiring? (September 2026)",
    x = "Number of postings mentioning this skill",
    y = NULL,
    caption = "Data source: Hacker News (https://news.ycombinator.com/item?id=49522897)"
  ) +
  theme_minimal(base_size = 13) +
  expand_limits(x = max(hn_skill_counts$n) * 1.2)

ggsave(here("output", "hn_skills.png"), plot = hn_skills,
       width = 8, height = 6, dpi = 300)