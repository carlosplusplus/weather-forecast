import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content","form", "spinner"];

  connect() {
    console.log("WeatherController connected");
  }

  // Triggered when the form is submitted
  showLoading(event) {
    console.log("made it to showLoading");
    // Prevent the default form submission behavior
    event.preventDefault();
    console.log("formTarget", this.formTarget);

    // Expand the weather report section
    this.contentTarget.classList.add("expanded");

    // Show the spinner
    this.spinnerTarget.classList.remove("hidden");

    console.log("right before requestSubmit");
    // Submit the form programmatically
    this.formTarget.requestSubmit();
    console.log("right after requestSubmit");
  }

  // Triggered when Turbo Frame content is loaded
  hideLoading() {
    console.log("made it to hideLoading");
    // Hide the spinner
    this.spinnerTarget.classList.add("hidden");

    // Ensure the content is visible
    this.contentTarget.classList.remove("hidden");
  }
}
