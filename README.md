# Job Skills Analysis

Web scraping analysis of remote and global tech job postings,
identifying the most in-demand technical skills.

## Research Question

**What technical skills do employers request most frequently
in remote and global tech job markets?**

This analysis combines three independent data sources to
cross-validate findings and avoid relying on a single platform.

## Data Sources

| # | Source | Type | Sample | Method |
|---|--------|------|--------|--------|
| 1 | [RemoteOK](https://remoteok.com) | JSON API | 99 postings | `httr2` + `jsonlite` |
| 2 | [We Work Remotely](https://weworkremotely.com) | RSS | 25 postings | `rvest` |
| 3 | [Hacker News "Who is Hiring?"](https://news.ycombinator.com/item?id=49522897) | HTML | 245 postings | `rvest` |

### Why three sources?

Each source has different strengths:

- **RemoteOK** provides structured skill tags, but only ~100 recent postings.
- **We Work Remotely** is a curated remote-only job board with rich job descriptions.
- **Hacker News** captures the global startup and tech hiring market, with 245+ postings per month.

Combining them reduces platform-specific bias and makes the
findings more robust.

### A note on RemoteOK and `rvest`

The assignment recommends using `rvest` for web scraping. I used
`rvest` for two of the three sources (We Work Remotely and Hacker
News), where HTML/RSS content is directly accessible.

For RemoteOK, I used their **public JSON API** instead. 

All three approaches are documented and reproducible.

## Repository Structure

```
blog2/
├── data/
│   ├── raw/                              
│   │   ├── remoteok_jobs_raw.csv
│   │   ├── wwr_jobs_raw.csv
│   │   └── hn_jobs_raw.csv
│   └── clean/                            
│       ├── remoteok_skills_clean.csv
│       ├── wwr_skills_clean.csv
│       └── hn_skills_clean.csv
├── code/                                 
│   ├── 01_remoteok_scraping.R
│   ├── 02_wwr_scraping.R
│   └── 03_hn_scraping.R
├── output/                           
│   ├── remoteok_skills.png
│   ├── wwr_skills.png
│   └── hn_skills.png
│   └── weekly_blog_2.rmd
└── README.md
```

## How to Reproduce

1. Clone this repository
2. Open the project in RStudio
3. Install required packages:

```r
install.packages(c("tidyverse", "rvest", "httr2", "jsonlite", "here"))
```

4. Run the scripts in order:

```r
source("code/01_remoteok_scraping.R")
source("code/02_wwr_scraping.R")
source("code/03_hn_scraping.R")
```

All outputs will be regenerated in `data/` and `output/`.

## Conclusion  
Across three independent sources and 369 job postings, the data
does not point to a single "most in-demand" skill. Instead, it
shows a **segmented market**:

- **Hacker News** (startup / full-stack): Python leads at 28%,
  followed by TypeScript and React.
- **We Work Remotely** (product-oriented remote companies):
  React leads at 40%, with AWS and CI/CD close behind.
- **RemoteOK** (infrastructure / DevOps): Go and system
  administration dominate.

The only skills that appear near the top on **more than one**
platform are **Python** and **React**. Cloud and DevOps tools
(AWS, Docker, CI/CD) recur across platforms but never as the
single top skill.

For someone unsure which segment to target, a low-regret starting point would be Python and React first, then
cloud/DevOps literacy. 

## Ethical Considerations

- All data sources are **publicly available** — no logins, CAPTCHAs,
  or paywalls were bypassed.
- RSS feeds and APIs were used where available to minimize server load.
- RemoteOK is credited as the data source per their API terms.
- Scraping was limited to a single request per source.

## Data Attribution

- RemoteOK — https://remoteok.com
- We Work Remotely — https://weworkremotely.com
- Hacker News "Who is Hiring?" — https://news.ycombinator.com

## License

This project is for educational purposes. All scraped data remains
the property of the original sources.