# ============================================================
# Data Source 2: We Work Remotely (RSS)
# Analyze skill demand in remote tech job postings
# ============================================================

library(tidyverse)   
library(rvest)       
library(here)        

# ============================================================

url_wwr <- "https://weworkremotely.com/categories/remote-programming-jobs.rss"
page_wwr <- read_html(url_wwr)
items_wwr <- page_wwr %>% html_elements("item")

length(items_wwr)   

# ============================================================

titles       <- items_wwr %>% html_element("title") %>% html_text2()
regions      <- items_wwr %>% html_element("region") %>% html_text2()
categories   <- items_wwr %>% html_element("category") %>% html_text2()
dates        <- items_wwr %>% html_element("pubdate") %>% html_text2()
descriptions <- items_wwr %>% html_element("description") %>% html_text2()


# ============================================================

wwr_raw <- tibble(
  title       = titles,
  region      = regions,
  category    = categories,
  date        = dates,
  description = descriptions
)

glimpse(wwr_raw)


dir.create(here("data", "raw"), recursive = TRUE, showWarnings = FALSE)
write_csv(wwr_raw, here("data", "raw", "wwr_jobs_raw.csv"))

# ============================================================

skills_list <- c(
  "Python", "JavaScript", "TypeScript", "Java", "Golang",
  "React", "Vue", "Angular", "Node", "Django", "Flask",
  "SQL", "PostgreSQL", "MySQL", "MongoDB",
  "AWS", "Azure", "GCP", "Docker", "Kubernetes",
  "Git", "CI/CD", "GraphQL",
  "Machine Learning", "TensorFlow", "PyTorch",
  "HTML", "CSS", "Linux", "Bash", "Rust"
)

wwr_skill_counts <- tibble(
  skill = skills_list,
  n = map_int(skills_list, function(s) {
    sum(str_detect(wwr_raw$description,
                   regex(paste0("\\b", s, "\\b"), ignore_case = TRUE)))
  })
) |>
  filter(n > 0) |>
  arrange(desc(n))

print(wwr_skill_counts, n = Inf)

dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write_csv(wwr_skill_counts, here("data", "clean", "wwr_skills_clean.csv"))

# ============================================================
p_wwr <- wwr_skill_counts |>
  mutate(skill = reorder(skill, n)) |>
  ggplot(aes(x = n, y = skill)) +
  geom_col(fill = "#2c7fb8") +
  geom_text(aes(label = n), hjust = -0.3, size = 3.5) +
  labs(
    title = "Most In-Demand Technical Skills in Remote Jobs",
    subtitle = "Based on 25 job postings from We Work Remotely",
    x = "Number of postings mentioning this skill",
    y = NULL,
    caption = "Data source: We Work Remotely (https://weworkremotely.com)"
  ) +
  theme_minimal(base_size = 13) +
  expand_limits(x = max(wwr_skill_counts$n) * 1.2)

p_wwr

dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)
ggsave(
  here("output", "wwr_skills.png"),
  plot = p_wwr,
  width = 8,
  height = 6,
  dpi = 300
)
