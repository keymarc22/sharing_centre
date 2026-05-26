import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { newUrl: String }

  selectDay(event) {
    event.stopPropagation()

    if (event.currentTarget.classList.contains('has-events')) {
      const eventsJson = event.currentTarget.dataset.events
      if (eventsJson) {
        try {
          this.showEventTooltip(event, JSON.parse(eventsJson))
        } catch (e) {
          console.error('Error parsing events:', e)
        }
      }
    } else {
      const date = event.currentTarget.dataset.date
      const modalEl = document.querySelector('[data-controller="ui--modal"]')
      if (!modalEl) return

      const frameEl = modalEl.querySelector('turbo-frame[id="modal"]')
      if (frameEl) {
        frameEl.src = `${this.newUrlValue}?date=${date}`
      }

      modalEl.classList.remove('hidden')
    }
  }

  showEventTooltip(event, events) {
    event.stopPropagation()
    document.querySelectorAll('.event-tooltip').forEach(t => t.remove())

    const tooltip = document.createElement('div')
    tooltip.className = 'event-tooltip'
    tooltip.innerHTML = events.map(e => {
      let startTime = ''
      if (e.start?.dateTime) {
        startTime = new Date(e.start.dateTime).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      } else if (typeof e.start === 'string') {
        startTime = new Date(e.start).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      }
      return `
        <div class="tooltip-event">
          <strong>${e.title || 'Unnamed'}</strong>
          ${startTime ? `<div class="event-time">${startTime}</div>` : ''}
          ${e.extendedProps?.teacher_name ? `<div class="event-time">Teacher: ${e.extendedProps.teacher_name}</div>` : ''}
          ${e.extendedProps?.meet_link ? `<a href="${e.extendedProps.meet_link}" target="_blank" rel="noopener">Join Class →</a>` : ''}
        </div>`
    }).join('')

    const rect = event.currentTarget.getBoundingClientRect()
    const tooltipWidth = 280
    let left = rect.right + 10
    if (left + tooltipWidth > window.innerWidth) left = rect.left - tooltipWidth - 10

    tooltip.style.cssText = `position:fixed;left:${left}px;top:${Math.max(10, rect.top)}px`
    document.body.appendChild(tooltip)

    setTimeout(() => {
      const close = () => { tooltip.remove(); document.removeEventListener('click', close) }
      document.addEventListener('click', close)
    }, 0)
  }
}
