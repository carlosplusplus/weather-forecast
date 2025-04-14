# 🌦️ Weather Forecast Application

This is a Ruby on Rails application that retrieves and displays weather forecast data for a given US address.

## 🎥 Demo Videos

1. **Retrieving a Weather Forecast**

==> LINK

2. **Retrieving a weather forecast from the cache**

==> LINK

3. **Handling an invalid address**

==> LINK

4. **Responsive UI**

==> LINK

## 📋 Initial Requirements

This project was developed based on the following requirements:

- **Framework**: Must be implemented in Ruby on Rails.
- **Input**: Accept a US address as input.
- **Functionality**:
  - Retrieve weather forecast data for the given address.
  - Display the current temperature.
  - (Bonus) Include high/low temperatures and an extended forecast.
- **Caching**:
  - Cache forecast data for 30 minutes by zip code.
  - Display an indicator if the result is retrieved from the cache.
- **Error Handling**: Handle invalid addresses and API failures gracefully.
- **Best Practices**:
  - Include unit tests.
  - Write clean, maintainable, and production-ready code.
  - Follow industry standards for naming conventions, encapsulation, and scalability.
- **UI**: Provide a user interface for entering the address and displaying the forecast.

## ✨ Features

- Accepts a US address as input.
- Retrieves weather forecast data from the nearest weather station, including:
  - Current temperature.
  - High/low temperatures.
  - Extended 5-day forecast.
- Caches forecast data for 30 minutes by zip code.
- Displays an indicator if the result is retrieved from the cache.
- Error handling for invalid addresses or API failures.

## 🛠️ Tech Stack & Tools

| Tech            | Usage                                   |
|------------------|-----------------------------------------|
| Ruby 3.4.2      | Language                                |
| Rails 8.0.2     | Web framework                           |
| Hotwire         | Real-time UI (Turbo + Stimulus)         |
| TailwindCSS     | Styling framework                       |
| RSpec           | Unit testing                            |
| Geocoding API   | Convert address → coordinates via `geocoder` gem          |
| Weather API     | Get forecast data from National Weather Service (NWS)
| Rails cache     | Store weather data by ZIP (30 min)      |

No API keys are required for this project.

## ⚙️ Setup and Installation

1. **Ensure the correct Ruby and Rails versions**:
   - This application requires **Ruby 3.4.2** and **Rails 8.0.2**.
   - Use a Ruby version manager like [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install the correct Ruby version:

     ```bash
     rbenv install 3.4.2
     rbenv global 3.4.2
     ```

   - Verify the Ruby version:

     ```bash
     ruby -v
     ```

   - Verify the Rails version:

     ```bash
     rails -v
2. **Clone the repository**:

   ```bash
   git clone https://github.com/carlosplusplus/weather-forecast.git
   cd weather-forecast
3. **Install dependencies**:

   ```bash
   bundle install
   ```

4. **Install `foreman` gem**:
   - Install `foreman` gem to manage processes locally:

   ```bash
   gem install foreman
   ```

5. **Install `foreman` gem**:
   - Use `foreman` to start the application with development `Procfile`:

   ```bash
   foreman start -f Procfile.dev
   ```

6. **Access the application**:
   - Open your browser and navigate to <http://localhost:5000>

## 📖 Usage

1. Enter a US address in the input form on the homepage.
2. Submit the form to retrieve the weather forecast from the nearest weather station.
3. If the forecast is cached, a "cached result" indicator will be displayed.

## 🗂️ Caching Strategy

- Forecast data is cached for 30 minutes by zip code using Rails' caching mechanism.
- This reduces redundant API calls and improves response times for frequently requested locations.

## ✅ Testing

Run the test suite with:

```bash
bundle exec rspec
```

The test suite is located in the `spec/` directory and includes the following:

- **Unit Tests**: Located in `spec/helpers/` and `spec/services/`, covering individual components like view helpers and service objects.
- **Controller Tests**: Located in `spec/controllers/`, testing request handling and error scenarios for fetching forecasts.

## 🔍 Decomposition of Objects

- **`GeocodingService`**: Converts addresses into latitude/longitude coordinates.
- **`WeatherService`**: Handles API calls to retrieve weather forecast data.
- **`ForecastsController`**: Manages user input and displays forecast data.

## 📐 Design and Scalability Considerations

- **Decomposition**: The application is divided into services (e.g., `WeatherService`, `GeocodingService`) to handle specific responsibilities.
- **Caching**: Rails' caching mechanism is used to store forecast data, reducing API calls and improving performance.
- **Error Handling**: Custom error classes (`GeocodingAddressError`, `GeocodingZipCodeError`) ensure robust error reporting.
- **Scalability**: The application is designed to handle increased traffic by leveraging caching and modular service objects.

## 🚀 Future Improvements

- Add support for international addresses.
- Improve UI/UX with more detailed weather visualizations.
- Implement user authentication for personalized forecasts.
- Add background jobs for pre-caching popular locations.
- Add `stimulus` behavior to forms for smoother data transitions.
- **Dockerize the application** to simplify local development and dependency management:
  - Create a `Dockerfile` to containerize the application.
  - Add a `docker-compose.yml` file to manage services like the Rails app, database, and caching layers.
  - Ensure the development environment is consistent across different machines.

## 📜 License

This project is open source and available under the [MIT License](LICENSE).
