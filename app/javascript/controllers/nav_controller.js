import { Controller } from "@hotwired/stimulus"

// Toggles the mobile navigation menu.
export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    this.openIconTarget.classList.toggle("hidden")
    this.closeIconTarget.classList.toggle("hidden")
    const expanded = !this.menuTarget.classList.contains("hidden")
    this.element.setAttribute("aria-expanded", expanded)
  }

  close() {
    if (this.menuTarget.classList.contains("hidden")) return
    this.menuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    this.element.setAttribute("aria-expanded", false)
  }
}
