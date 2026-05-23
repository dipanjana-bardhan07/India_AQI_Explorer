# ============================================================
#  India AQI Explorer — R Shiny Dashboard
# ============================================================

required_pkgs <- c("shiny", "tidyverse", "lubridate", "ggplot2", "readr", "dplyr")
for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}

library(shiny)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(readr)
library(dplyr)

# ============================================================
#  CSS
# ============================================================
css <- "
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  html {
    height: 100%;
    overflow: hidden;
  }

  body {
    height: 100%;
    overflow: hidden;
    background: #0b0f1a;
    color: #e2e8f0;
    font-family: 'Sora', sans-serif;
  }

  /* Shiny root divs — all must be 100% height */
  .container-fluid,
  .container-fluid > div {
    padding: 0 !important;
    height: 100%;
  }

  /* ── Full page flex column ── */
  .page-root {
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
  }

  /* ── Top header: fixed 58px ── */
  .top-header {
    flex: 0 0 58px;
    background: linear-gradient(90deg,#0f172a 0%,#1e293b 50%,#0f172a 100%);
    border-bottom: 1px solid rgba(56,189,248,0.2);
    padding: 0 32px;
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .header-icon {
    width: 34px; height: 34px;
    background: linear-gradient(135deg,#38bdf8,#818cf8);
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: 17px;
  }
  .header-title {
    font-size: 19px; font-weight: 700; letter-spacing: -0.5px;
    background: linear-gradient(90deg,#f0f9ff,#bae6fd,#818cf8);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .header-sub {
    margin-left: auto;
    font-size: 11px;
    font-family: 'JetBrains Mono', monospace;
    color: #64748b;
    letter-spacing: 0.05em;
  }

  /* ── Body row: fills everything below header ── */
  .body-row {
    flex: 1 1 0;
    display: flex;
    min-height: 0;
    overflow: hidden;
  }

  /* ── Sidebar: fixed 268px ── */
  .sidebar-panel {
    flex: 0 0 268px;
    background: #0f172a;
    border-right: 1px solid rgba(56,189,248,0.12);
    padding: 22px 18px;
    display: flex;
    flex-direction: column;
    gap: 16px;
    overflow: hidden;
  }
  .sidebar-label {
    font-size: 10px; font-weight: 600;
    letter-spacing: 0.15em; text-transform: uppercase;
    color: #38bdf8; margin-bottom: 8px;
  }
  .sidebar-panel select {
    width: 100%;
    background: #1e293b;
    color: #e2e8f0;
    border: 1px solid rgba(56,189,248,0.25);
    border-radius: 10px;
    padding: 9px 12px;
    font-family: 'Sora', sans-serif;
    font-size: 13px;
    appearance: none;
    -webkit-appearance: none;
    cursor: pointer;
    transition: border-color 0.2s;
  }
  .sidebar-panel select:focus {
    outline: none;
    border-color: #38bdf8;
    box-shadow: 0 0 0 3px rgba(56,189,248,0.15);
  }
  .sidebar-panel select option { background: #1e293b; }

  .stat-card {
    background: linear-gradient(135deg,#1e293b,#162032);
    border: 1px solid rgba(56,189,248,0.12);
    border-radius: 11px;
    padding: 11px 14px;
  }
  .stat-card + .stat-card { margin-top: 10px; }
  .stat-card-label {
    font-size: 10px; color: #64748b;
    letter-spacing: 0.08em; text-transform: uppercase; margin-bottom: 3px;
  }
  .stat-card-value {
    font-family: 'JetBrains Mono', monospace;
    font-size: 19px; font-weight: 600; color: #38bdf8;
  }
  .stat-card-sub { font-size: 10px; color: #475569; margin-top: 2px; }

  .desc-box {
    background: rgba(56,189,248,0.05);
    border-left: 3px solid #38bdf8;
    border-radius: 0 8px 8px 0;
    padding: 11px 13px;
    font-size: 11px; color: #94a3b8; line-height: 1.65;
  }

  /* ── Main panel: fills rest of body-row ── */
  .main-panel {
    flex: 1 1 0;
    min-width: 0;
    min-height: 0;
    display: flex;
    flex-direction: column;
    padding: 16px 22px;
    gap: 12px;
    overflow: hidden;
  }

  /* ML metric pills — shrink-proof */
  .metrics-row {
    flex: 0 0 auto;
    display: flex; gap: 10px; flex-wrap: wrap;
  }
  .metric-pill {
    background: linear-gradient(135deg,#1e293b,#162032);
    border: 1px solid rgba(56,189,248,0.2);
    border-radius: 50px; padding: 7px 16px;
    display: flex; align-items: center; gap: 9px;
  }
  .metric-pill-label { font-size: 10px; color: #64748b; text-transform: uppercase; letter-spacing: 0.1em; }
  .metric-pill-value {
    font-family: 'JetBrains Mono', monospace;
    font-size: 14px; font-weight: 600; color: #34d399;
  }

  /* ── Viz card: stretches to fill ALL remaining space ── */
  .viz-card {
    flex: 1 1 0;
    min-height: 0;
    background: #111827;
    border: 1px solid rgba(255,255,255,0.06);
    border-radius: 14px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    animation: fadeSlide 0.3s ease both;
  }
  @keyframes fadeSlide {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  /* Card header: fixed height */
  .viz-card-header {
    flex: 0 0 auto;
    padding: 13px 20px 11px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    display: flex; align-items: center; gap: 11px;
  }
  .viz-badge {
    background: linear-gradient(135deg,#38bdf8,#818cf8);
    color: #0f172a; font-size: 10px; font-weight: 700;
    letter-spacing: 0.1em; padding: 3px 9px;
    border-radius: 20px; text-transform: uppercase;
    white-space: nowrap;
  }
  .viz-title {
    font-size: 14px; font-weight: 600; color: #f1f5f9; letter-spacing: -0.3px;
  }

  /* Card body: takes ALL remaining card height */
  .viz-card-body {
    flex: 1 1 0;
    min-height: 0;
    position: relative;
  }

  /* Plot output fills card body absolutely */
  #main_plot {
    position: absolute !important;
    top: 0; left: 0; right: 0; bottom: 0;
    width: 100% !important;
    height: 100% !important;
  }

  /* Shiny overrides */
  .shiny-input-container { margin-bottom: 0 !important; }
  label { display: none !important; }
"

# ============================================================
#  UI
# ============================================================
ui <- fluidPage(

  tags$head(
    tags$link(
      rel  = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Sora:wght@300;400;600;700&family=JetBrains+Mono:wght@400;600&display=swap"
    ),
    tags$style(HTML(css)),

    tags$script(HTML("
      function syncPlotHeight() {
        var body = document.querySelector('.viz-card-body');
        var plot = document.getElementById('main_plot');
        if (body && plot) {
          var h = body.getBoundingClientRect().height;
          plot.style.height = Math.max(h, 150) + 'px';
        }
      }
      document.addEventListener('DOMContentLoaded', function() {
        syncPlotHeight();
        window.addEventListener('resize', syncPlotHeight);
        // Re-sync after Shiny redraws
        $(document).on('shiny:value shiny:recalculating shiny:recalculated', syncPlotHeight);
        // ResizeObserver for robustness
        var body = document.querySelector('.viz-card-body');
        if (body && window.ResizeObserver) {
          new ResizeObserver(syncPlotHeight).observe(body);
        }
      });
    "))
  ),

  div(class = "page-root",

    # ── Header ───────────────────────────────────────────────
    div(class = "top-header",
      div(class = "header-icon", "\U0001f32b"),
      div(class = "header-title", "India AQI Explorer"),
      div(class = "header-sub",
          "city_day.csv  \u2022  Pollution Analytics Dashboard")
    ),

    # ── Body row ─────────────────────────────────────────────
    div(class = "body-row",

      # LEFT SIDEBAR
      div(class = "sidebar-panel",
        div(
          div(class = "sidebar-label", "Select Visualization"),
          selectInput(
            inputId  = "viz_choice",
            label    = NULL,
            choices  = c(
              "Pan-India AQI Trend"          = "trend",
              "Top 10 Polluted Cities"       = "top10",
              "AQI Bucket Distribution"      = "bucket",
              "Monthly AQI Pattern"          = "monthly",
              "Actual vs Predicted AQI (ML)" = "model"
            ),
            selected = "trend"
          )
        ),
        uiOutput("sidebar_stats"),
        div(class = "desc-box", uiOutput("viz_description"))
      ),

      # RIGHT MAIN
      div(class = "main-panel",

        # ML pills
        conditionalPanel(
          condition = "input.viz_choice === 'model'",
          div(class = "metrics-row",
            div(class = "metric-pill",
              div(class = "metric-pill-label", "RMSE"),
              div(class = "metric-pill-value",
                  textOutput("rmse_val", inline = TRUE))
            ),
            div(class = "metric-pill",
              div(class = "metric-pill-label", "R\u00b2"),
              div(class = "metric-pill-value",
                  textOutput("r2_val", inline = TRUE))
            ),
            div(class = "metric-pill",
              div(class = "metric-pill-label", "Training Rows"),
              div(class = "metric-pill-value",
                  textOutput("train_size", inline = TRUE))
            )
          )
        ),

        # Viz card
        div(class = "viz-card",
          div(class = "viz-card-header",
            div(class = "viz-badge", uiOutput("viz_badge_label")),
            div(class = "viz-title",  uiOutput("viz_card_title"))
          ),
          div(class = "viz-card-body",
            plotOutput("main_plot", width = "100%", height = "100%")
          )
        )
      )
    )
  )
)

# ============================================================
#  SERVER
# ============================================================
server <- function(input, output, session) {

  # ── Data ──────────────────────────────────────────────────
  city_day_raw <- reactive({
    req(file.exists("city_day.csv"))
    df <- read_csv("city_day.csv", show_col_types = FALSE)
    df$Date <- as.Date(df$Date, format = "%Y-%m-%d")
    df
  })
  city_day_clean <- reactive({ city_day_raw() %>% drop_na(AQI) })

  daily_avg <- reactive({
    city_day_clean() %>%
      group_by(Date) %>%
      summarise(Avg_AQI = mean(AQI, na.rm = TRUE), .groups = "drop")
  })
  top_cities <- reactive({
    city_day_clean() %>%
      group_by(City) %>%
      summarise(Avg_AQI = mean(AQI, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(Avg_AQI)) %>% slice(1:10)
  })
  bucket_dist <- reactive({
    top5 <- top_cities()$City[1:5]
    city_day_clean() %>%
      filter(City %in% top5) %>%
      group_by(City, AQI_Bucket) %>%
      summarise(Days = n(), .groups = "drop")
  })
  monthly_aqi <- reactive({
    city_day_clean() %>%
      mutate(Month = format(Date, "%m")) %>%
      group_by(Month) %>%
      summarise(Average_AQI = mean(AQI, na.rm = TRUE), .groups = "drop")
  })
  model_results <- reactive({
    cols <- c("AQI","PM2.5","PM10","NO","NO2","NOx","NH3","CO","SO2","O3")
    dat  <- city_day_clean() %>% select(any_of(cols)) %>% drop_na()
    set.seed(123)
    idx   <- sample(seq_len(nrow(dat)), 0.8 * nrow(dat))
    train <- dat[idx, ]; test <- dat[-idx, ]
    mdl   <- lm(AQI ~ ., data = train)
    preds <- predict(mdl, newdata = test)
    list(
      actual  = test$AQI, predicted = preds,
      rmse    = sqrt(mean((preds - test$AQI)^2)),
      r2      = 1 - sum((test$AQI - preds)^2) /
                    sum((test$AQI - mean(test$AQI))^2),
      train_n = nrow(train)
    )
  })

  # ── Dark theme ────────────────────────────────────────────
  dark_theme <- function() {
    theme_minimal(base_family = "sans") +
      theme(
        plot.background   = element_rect(fill = "#111827", color = NA),
        panel.background  = element_rect(fill = "#111827", color = NA),
        panel.grid.major  = element_line(color = "#1e293b", linewidth = 0.5),
        panel.grid.minor  = element_blank(),
        axis.text         = element_text(color = "#94a3b8", size = 10),
        axis.title        = element_text(color = "#cbd5e1", size = 11,
                                         face = "bold"),
        plot.title        = element_text(color = "#f1f5f9", size = 14,
                                         face = "bold", margin = margin(b = 4)),
        plot.subtitle     = element_text(color = "#64748b", size = 10),
        legend.background = element_rect(fill = "#1e293b", color = NA),
        legend.text       = element_text(color = "#94a3b8"),
        legend.title      = element_text(color = "#cbd5e1"),
        strip.text        = element_text(color = "#e2e8f0", face = "bold",
                                         size = 10),
        strip.background  = element_rect(fill = "#1e293b", color = NA),
        plot.margin       = margin(12, 16, 12, 16)
      )
  }

  # ── Plot — height="100%" lets JS drive actual px ──────────
  output$main_plot <- renderPlot({
    choice <- input$viz_choice

    if (choice == "trend") {
      d <- daily_avg()
      ggplot(d, aes(x = Date, y = Avg_AQI)) +
        geom_area(fill = "#1e40af", alpha = 0.25) +
        geom_line(color = "#38bdf8", linewidth = 0.9) +
        labs(title = "Pan-India Average AQI Over Time",
             subtitle = "Daily average across all monitored cities",
             x = "Date", y = "Average AQI") +
        dark_theme()

    } else if (choice == "top10") {
      d <- top_cities()
      ggplot(d, aes(x = reorder(City, Avg_AQI), y = Avg_AQI, fill = Avg_AQI)) +
        geom_bar(stat = "identity", width = 0.7, show.legend = FALSE) +
        geom_text(aes(label = round(Avg_AQI, 0)),
                  hjust = -0.2, color = "#94a3b8", size = 3.4) +
        coord_flip() +
        scale_fill_gradient(low = "#f59e0b", high = "#ef4444") +
        scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
        labs(title = "Top 10 Most Polluted Cities in India",
             subtitle = "Ranked by average AQI",
             x = NULL, y = "Average AQI") +
        dark_theme()

    } else if (choice == "bucket") {
      d <- bucket_dist()
      bcols <- c("Good"="#22c55e","Satisfactory"="#84cc16","Moderate"="#eab308",
                 "Poor"="#f97316","Very Poor"="#ef4444","Severe"="#9b1c1c")
      ggplot(d, aes(x = AQI_Bucket, y = Days, fill = AQI_Bucket)) +
        geom_bar(stat = "identity", show.legend = FALSE) +
        facet_wrap(~City, ncol = 3) +
        scale_fill_manual(values = bcols, na.value = "#475569") +
        labs(title = "AQI Bucket Distribution \u2014 Top 5 Polluted Cities",
             subtitle = "Number of days spent in each pollution category",
             x = "AQI Category", y = "Number of Days") +
        dark_theme() +
        theme(axis.text.x = element_text(angle = 38, hjust = 1, size = 8))

    } else if (choice == "monthly") {
      d  <- monthly_aqi()
      ml <- c("Jan","Feb","Mar","Apr","May","Jun",
               "Jul","Aug","Sep","Oct","Nov","Dec")
      d$Month_Label <- factor(ml[as.integer(d$Month)], levels = ml)
      ggplot(d, aes(x = Month_Label, y = Average_AQI, group = 1)) +
        geom_ribbon(aes(ymin = min(Average_AQI), ymax = Average_AQI),
                    fill = "#818cf8", alpha = 0.15) +
        geom_line(color = "#818cf8", linewidth = 1.3) +
        geom_point(color = "#f472b6", size = 3.5, shape = 21,
                   fill = "#0f172a", stroke = 2) +
        geom_text(aes(label = round(Average_AQI, 0)),
                  vjust = -1.3, color = "#94a3b8", size = 3) +
        labs(title = "Monthly Average AQI Across India",
             subtitle = "Seasonal pollution pattern aggregated across all years",
             x = "Month", y = "Average AQI") +
        dark_theme()

    } else if (choice == "model") {
      res <- model_results()
      df  <- data.frame(Actual = res$actual, Predicted = res$predicted)
      ggplot(df, aes(x = Actual, y = Predicted)) +
        geom_point(alpha = 0.3, color = "#38bdf8", size = 1.4) +
        geom_abline(slope = 1, intercept = 0,
                    color = "#f472b6", linetype = "dashed", linewidth = 1.1) +
        labs(title = "Actual vs Predicted AQI",
             subtitle = "Linear regression \u2014 dashed line = perfect prediction",
             x = "Actual AQI", y = "Predicted AQI") +
        dark_theme()
    }

  }, bg = "#111827")

  # ── ML metrics ────────────────────────────────────────────
  output$rmse_val   <- renderText({
    req(input$viz_choice == "model"); round(model_results()$rmse, 2) })
  output$r2_val     <- renderText({
    req(input$viz_choice == "model"); round(model_results()$r2, 3) })
  output$train_size <- renderText({
    req(input$viz_choice == "model");
    paste0(model_results()$train_n, " rows") })

  # ── Sidebar stat cards ────────────────────────────────────
  output$sidebar_stats <- renderUI({
    choice <- input$viz_choice
    clean  <- city_day_clean()
    if (choice == "trend") {
      tagList(
        div(class = "stat-card",
          div(class = "stat-card-label", "Date Range"),
          div(class = "stat-card-value",
              paste(format(min(clean$Date), "%Y"), "\u2013",
                    format(max(clean$Date), "%Y"))),
          div(class = "stat-card-sub", "Years of data")),
        div(class = "stat-card",
          div(class = "stat-card-label", "Peak Daily Avg AQI"),
          div(class = "stat-card-value", round(max(daily_avg()$Avg_AQI), 0)),
          div(class = "stat-card-sub", "Highest single-day average"))
      )
    } else if (choice == "top10") {
      tc <- top_cities()
      tagList(
        div(class = "stat-card",
          div(class = "stat-card-label", "Most Polluted City"),
          div(class = "stat-card-value", tc$City[1]),
          div(class = "stat-card-sub",
              paste("Avg AQI:", round(tc$Avg_AQI[1], 0)))),
        div(class = "stat-card",
          div(class = "stat-card-label", "Cities Monitored"),
          div(class = "stat-card-value", n_distinct(clean$City)),
          div(class = "stat-card-sub", "Unique cities in dataset"))
      )
    } else if (choice == "bucket") {
      tagList(div(class = "stat-card",
        div(class = "stat-card-label", "Cities Shown"),
        div(class = "stat-card-value", "Top 5"),
        div(class = "stat-card-sub", "By average AQI rank")))
    } else if (choice == "monthly") {
      m  <- monthly_aqi()
      ml <- c("Jan","Feb","Mar","Apr","May","Jun",
               "Jul","Aug","Sep","Oct","Nov","Dec")
      worst <- ml[as.integer(m$Month[which.max(m$Average_AQI)])]
      tagList(div(class = "stat-card",
        div(class = "stat-card-label", "Worst Month"),
        div(class = "stat-card-value", worst),
        div(class = "stat-card-sub",
            paste("Avg AQI:", round(max(m$Average_AQI), 0)))))
    } else if (choice == "model") {
      tagList(div(class = "stat-card",
        div(class = "stat-card-label", "Model Type"),
        div(class = "stat-card-value", "OLS"),
        div(class = "stat-card-sub", "10-variable linear regression")))
    }
  })

  # ── Badge / title / description ───────────────────────────
  badge_map <- c(trend="Time Series", top10="Bar Chart",
                 bucket="Faceted Bar", monthly="Line Chart",
                 model="ML Regression")
  title_map <- c(
    trend   = "Pan-India Average AQI Over Time",
    top10   = "Top 10 Most Polluted Cities in India",
    bucket  = "AQI Bucket Distribution \u2014 Top 5 Cities",
    monthly = "Monthly Average AQI Pattern",
    model   = "Actual vs Predicted AQI (Linear Regression)")
  desc_map <- c(
    trend   = "Daily average AQI across all Indian cities, revealing long-term trends and seasonal spikes.",
    top10   = "Cities ranked by mean AQI. Color intensity scales with pollution severity.",
    bucket  = "Days each top-5 city spent in each AQI bucket, from Good to Severe.",
    monthly = "Seasonal rhythm of Indian air quality averaged across all years.",
    model   = "Linear regression on 10 pollutants. Dashed line = perfect prediction.")

  output$viz_badge_label <- renderUI({ badge_map[input$viz_choice] })
  output$viz_card_title  <- renderUI({ title_map[input$viz_choice] })
  output$viz_description <- renderUI({ desc_map[input$viz_choice] })
}

# ============================================================
#  Run
# ============================================================
shinyApp(ui = ui, server = server)
