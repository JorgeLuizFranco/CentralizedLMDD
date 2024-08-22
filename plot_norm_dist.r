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

# Load the tidy data
data <- read_csv("./julia/normalized_distances.csv")

# Determine the indices of the boxes to keep (every 2nd value)
indices_to_keep <- seq(1, max(data$Number_of_Drones), by = 2)

# Filter the data to include only the specified boxes
filtered_data <- data %>% filter(Number_of_Drones %in% indices_to_keep)

# Specify the values to display on the x-axis
x_axis_values <- c(1, 51, 99)

# Create a line plot with points using the first color from the IEEE palette
normalized_distance_plot <- ggplot(filtered_data %>%
                                     group_by(Number_of_Drones) %>%
                                     summarise(Normalized_Distance = median(Normalized_Distance)),
                                   aes(x = Number_of_Drones, y = Normalized_Distance)) +
  geom_line(color = ieee_palette[1]) +
  geom_point(color = ieee_palette[1], size = 0.9) +  # Reduce the size of the points
  ieee_theme(legend.position = "bottom") +
  labs(x = "Number of drones", y = "Normalized distance") +
  scale_x_continuous(breaks = x_axis_values)

# Save the plot
ggsave("normalized_distance_plot.pdf", normalized_distance_plot, width = 80, height = 80, units = "mm")

# Display the plot
print(normalized_distance_plot)
