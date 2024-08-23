library(tidyverse)

ieee_palette <- c("#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#ffffff")

ieee_theme <- function(font.size = 10, font.family = 'Times', ...) {
    require('ggplot2')
    theme_bw() +
    theme(text = element_text(family = font.family, size = font.size),
          #axis.line = element_line(colour = "black"),
          panel.grid.major = element_line(colour = 'light gray', linetype = 'dashed'),
          panel.grid.minor = element_blank(),
          panel.border = element_rect(colour = 'black'),
          panel.background = element_blank(),
          legend.key = element_blank(),#rect(color = 'black', fill = 'white'),
          legend.text = element_text(family = font.family, size = round(font.size * 0.8)),
          strip.background = element_rect(colour = 'black', fill = '#EEEEEE'),
          ...)
}

data <-
  read_csv(list.files(".", pattern = "*.csv"),
           id = "file_name")

data <-
  data %>%
  separate(file_name, into=c("Language", "Variable", "Foo"), sep="_") %>%
  select(-c(Language, Foo))

data <-
  data %>%
  select(Drones = Group, Method = Label, Variable, Value = Data)

time_plot <-
  ggplot(data %>%
          filter(Variable == "time") %>%
          group_by(Drones, Method) %>%
          summarise(Value = median(Value)),
         aes(x = Drones, y = Value, color = Method)) +
  geom_line() +
  geom_point() +
  ieee_theme(legend.position = "bottom") +
  scale_color_manual(values = ieee_palette) +
  labs(x = "Number of drones", y = "Execution time (s)") +
  scale_y_log10()


objective_plot <-
  ggplot(data %>% filter(Variable == "obj"),
         aes(x = factor(Drones), y = Value, fill = Method)) +
  geom_boxplot(fatten=1.1) + ieee_theme(legend.position = "bottom") +
  scale_fill_manual(values = ieee_palette) +
  labs(x = "Number of drones", y = "Average path length")

ggsave("time_plot.pdf", time_plot, width = 160, height = 90, units = "mm")
ggsave("objective_plot.pdf", objective_plot, width = 160, height = 90, units = "mm")
