import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoHide: { type: Boolean, default: true },
    timeout: { type: Number, default: 5000 }
  }

  connect() {
    // entrance animation
    requestAnimationFrame(() => {
      this.element.classList.remove('translate-x-4', 'opacity-0')
      this.element.classList.add('translate-x-0', 'opacity-100')
    })

    this.element.addEventListener('mouseenter', () => this.pauseTimer())
    this.element.addEventListener('mouseleave', () => this.resumeTimer())

    if (this.autoHideValue) this.startTimer()
  }

  disconnect() {
    this.clearTimer()
  }

  hide() {
    // exit animation
    this.element.classList.remove('translate-x-0', 'opacity-100')
    this.element.classList.add('translate-x-4', 'opacity-0')
    // wait transition (match duration-300)
    setTimeout(() => {
      if (this.element && this.element.parentNode) this.element.remove()
    }, 300)
  }

  startTimer() {
    this.clearTimer()
    this._remaining = this.timeoutValue
    this._startAt = Date.now()
    this._timer = setTimeout(() => this.hide(), this._remaining)
  }

  pauseTimer() {
    if (!this._timer) return
    clearTimeout(this._timer)
    this._timer = null
    this._remaining = Math.max(0, this._remaining - (Date.now() - this._startAt))
  }

  resumeTimer() {
    if (this._timer) return
    this._startAt = Date.now()
    this._timer = setTimeout(() => this.hide(), this._remaining)
  }

  clearTimer() {
    if (this._timer) {
      clearTimeout(this._timer)
      this._timer = null
    }
  }
}