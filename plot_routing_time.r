library(tidyverse)

# Define the IEEE palette and the theme function
ieee_palette <- c("#e66101", "#5e3c99", "#fdb863", "#b2abd2", "#ffffff")

ieee_theme <- function(font.size = 10, font.family = 'Times', ...) {
    theme_bw() +
    theme(
        text = element_text(family = font.family, size = font.size),
        panel.grid.major = element_line(colour = 'light gray', linetype = 'dashed'),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = 'black'),
        panel.background = element_blank(),
        legend.key = element_blank(),
        legend.text = element_text(family = font.family, size = round(font.size * 0.8)),
        strip.background = element_rect(colour = 'black', fill = '#EEEEEE'),
        ...
    )
}

# Load the tidy data for routing times
data <- read_csv("./julia/routing_times.csv")

# Determine the indices of the boxes to keep (every 5th value)
indices_to_keep <- seq(1, max(data$Number_of_Drones), by = 2)

# Filter the data to include only the specified boxes
filtered_data <- data %>% filter(Number_of_Drones %in% indices_to_keep)

# Specify the values to display on the x-axis
x_axis_values <- c(1, 51, 99)

# Create a boxplot using a single color from the IEEE palette
routing_time_plot <- ggplot(filtered_data, aes(x = factor(Number_of_Drones), y = Routing_Time, fill = factor(Number_of_Drones))) +
    geom_boxplot(fill = ieee_palette[1], outlier.color = ieee_palette[1], outlier.size = 0.1) +
    ieee_theme(legend.position = "none") +
    labs(x = "Number of drones", y = "Routing time") +
    scale_x_discrete(breaks = x_axis_values)

# Save the plot
ggsave("routing_time_plot.pdf", routing_time_plot, width = 80, height = 80, units = "mm")

# Display the plot
print(routing_time_plot)
