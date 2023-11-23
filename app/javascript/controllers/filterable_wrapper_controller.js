import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filtersForm", "closeFiltersFormBtn", "viewsList"]

  static classes = ["hidden"]

  openViews(event) {
    event.stopPropagation();

    if (this._viewsListOpened) {
      return this.closeViews(event);
    }

    this._viewsListOpened = true;
    this.viewsListTarget.classList.remove(this.hiddenClass);
    this.closeViewsListOnClickOutside = this.closeViews.bind(this);
    window.addEventListener("click", this.closeViewsListOnClickOutside);
  }

  closeViews(event) {
    if (this.viewsListTarget.contains(event.target)) {
      return;
    }
    this._viewsListOpened = false;
    this.viewsListTarget.classList.add(this.hiddenClass);
    window.removeEventListener("click", this.closeViewsListOnClickOutside);
    this.closeViewsListOnClickOutside = null;
  }

  openFilters(event) {
    event.stopPropagation();

    if (this._filtersFormOpened) {
      return this.closeFilters(event);
    }

    this._filtersFormOpened = true;
    this.filtersFormTarget.classList.remove(this.hiddenClass);
    this.closeFiltersFormOnClickOutside = this.closeFilters.bind(this);
    window.addEventListener("click", this.closeFiltersFormOnClickOutside);
  }

  closeFilters(event) {
    if (this.filtersFormTarget.contains(event.target) && event.target !== this.closeFiltersFormBtnTarget) {
      return;
    }
    this._filtersFormOpened = false;
    this.filtersFormTarget.classList.add(this.hiddenClass);
    window.removeEventListener("click", this.closeFiltersFormOnClickOutside);
    this.closeFiltersFormOnClickOutside = null;
  }
}
