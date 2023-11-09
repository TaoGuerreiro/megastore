import { Controller } from '@hotwired/stimulus'
import Trix from 'trix'

// Connects to data-controller="trix"
export default class extends Controller {
  static targets = ['editor', 'foregroundColorPicker', 'backgroundColorPicker']

  connect () {
    this.initTrix()
    this.reloadOriginalContent()
  }

  initTrix () {
    if (this.hasForegroundColorPickerTarget) { return }

    Trix.config.blockAttributes.heading1.tagName = 'h3'
    this.addForegroundButtonInToolbar()
    this.addBackgroundButtonInToolbar()
    this.addTextAlignCenterButtonInToolbar()
  }

  reloadOriginalContent () {
    this.editorTarget.reset()
  }

  openForegroundColorPicker () {
    this.foregroundColorPickerTarget.click()
  }

  openBackgroundColorPicker () {
    this.backgroundColorPickerTarget.click()
  }

  foregroundColorChanged () {
    this.editorTarget.editor.activateAttribute('foregroundColor', this.foregroundColorPickerTarget.value)
  }

  backgroundColorChanged () {
    this.editorTarget.editor.activateAttribute('backgroundColor', this.backgroundColorPickerTarget.value)
  }

  addForegroundButtonInToolbar () {
    Trix.config.textAttributes.foregroundColor = {
      styleProperty: 'color',
      inheritable: true
    }

    this.element
      .querySelector('.trix-button-group.trix-button-group--text-tools')
      .insertAdjacentHTML('beforeend', this.foregroundColorButtons)
  }

  addBackgroundButtonInToolbar () {
    Trix.config.textAttributes.backgroundColor = {
      styleProperty: 'backgroundColor',
      inheritable: true
    }

    this.element
      .querySelector('.trix-button-group.trix-button-group--text-tools')
      .insertAdjacentHTML('beforeend', this.backgroundColorButtons)
  }

  addTextAlignCenterButtonInToolbar () {
    Trix.config.blockAttributes.textAlignCenter = {
      tagName: 'centered-div'
    }

    this.element
      .querySelector('.trix-button-group.trix-button-group--block-tools')
      .insertAdjacentHTML('beforeend', this.textAlignButtons)
  }

  get foregroundColorButtons () {
    return `<input type="color" style="width:0;height:0;padding:0;margin-top:20px;visibility:hidden"
                   data-trix-target="foregroundColorPicker" data-action="trix#foregroundColorChanged">
            <button type="button" class="trix-button" data-action="click->trix#openForegroundColorPicker" title="Text color">
              <span class="icon"><i class="fas fa-palette fa-lg"></i></span>
            </button>`
  }

  get backgroundColorButtons () {
    return `<input type="color" style="width:0;height:0;padding:0;margin-top:20px;visibility:hidden"
                   data-trix-target="backgroundColorPicker" data-action="trix#backgroundColorChanged">
            <button type="button" class="trix-button" data-action="click->trix#openBackgroundColorPicker" title="Text background color">
              <span class="icon"><i class="fas fa-fill-drip fa-lg"></i></span>
            </button>`
  }

  get textAlignButtons () {
    return `<button type="button" class="trix-button" data-trix-attribute="textAlignCenter">
              <span class="icon"><i class="fas fa-align-center fa-lg"></i></span>
            </button>`
  }
}
