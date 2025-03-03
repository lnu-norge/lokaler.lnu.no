import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "wrapper", "background", "focus", "content", "template", "closeButton" ]

  // Elements that can receive focus
  focusableElements = [
    'a[href]',
    'button:not([disabled])',
    'input:not([disabled])',
    'select:not([disabled])',
    'textarea:not([disabled])',
    '[tabindex="0"]'
  ]
  
  // Reference to store the element that had focus before opening the modal
  previouslyFocusedElement = null

  connect() {
    this.connectBackground()
    this.handleKeyboard = this.handleKeyboard.bind(this)
    
    // Add keyboard event listener when connected
    document.addEventListener('keydown', this.handleKeyboard)
  }

  disconnect() {
    super.disconnect()
    
    // Remove keyboard event listener when disconnected
    document.removeEventListener('keydown', this.handleKeyboard)
    
    // Enable scrolling on body
    document.body.classList.remove("overflow-hidden")
    
    // Restore focus to the element that had focus before opening the modal
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }
  }

  connectBackground() {
    if (!this.hasBackgroundTarget) return
    
    this.backgroundTarget.onclick = (event) => {
      // Check that we didn't click anything else:
      if (event.target !== this.backgroundTarget) return

      // Then close the modal:
      this.close()
    }
  }

  // Handle keyboard events (Escape and Tab navigation)
  handleKeyboard(event) {
    // Only handle keyboard events if the modal is in global_modal
    const globalModal = document.getElementById('global_modal')
    if (!globalModal || !globalModal.contains(this.element)) return
    
    // Close modal on Escape key
    if (event.key === 'Escape') {
      this.close()
      event.preventDefault()
      return
    }
    
    // Handle Tab key for focus trapping
    if (event.key === 'Tab') {
      this.handleTabKey(event)
    }
  }
  
  // Handle Tab key to trap focus inside modal
  handleTabKey(event) {
    // Get all focusable elements in the modal
    const focusableElements = this.element.querySelectorAll(this.focusableElements.join(','))
    const firstFocusable = focusableElements[0]
    const lastFocusable = focusableElements[focusableElements.length - 1]
    
    // If there are no focusable elements, don't do anything
    if (focusableElements.length === 0) return
    
    // If Shift+Tab on first element, move to last element
    if (event.shiftKey && document.activeElement === firstFocusable) {
      lastFocusable.focus()
      event.preventDefault()
    } 
    // If Tab on last element, move to first element
    else if (!event.shiftKey && document.activeElement === lastFocusable) {
      firstFocusable.focus()
      event.preventDefault()
    }
  }

  close() {
    // Clear the global modal
    const globalModal = document.getElementById('global_modal')
    if (globalModal) {
      globalModal.innerHTML = ''
    }
    
    // Update ARIA attributes on open button
    const openButton = document.querySelector(`[data-modal-id-param="${this.element.dataset.modalId}"]`)
    if (openButton) {
      openButton.setAttribute('aria-expanded', 'false')
    }
    
    // Enable scrolling on body
    document.body.classList.remove("overflow-hidden")
    
    // Restore focus
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }
  }

  open() {
    // Save the currently focused element to restore later
    this.previouslyFocusedElement = document.activeElement
    
    // Get modal ID from the data attribute
    const idToOpen = this.element.dataset.modalIdParam
    if (!idToOpen) return

    // Find the template for this modal
    const template = document.querySelector(`template[data-modal-id="${idToOpen}"]`)
    if (!template) return
      
    // Clone the template content
    const modalContent = template.content.cloneNode(true)
    
    // Insert into global modal frame
    const globalModal = document.getElementById('global_modal')
    if (!globalModal) return
    
    // Clear existing content
    globalModal.innerHTML = ''
    
    // Add the new content
    globalModal.appendChild(modalContent)
    
    // Update ARIA attributes on open button
    this.element.setAttribute('aria-expanded', 'true')
    
    // Disable scrolling on body
    document.body.classList.add("overflow-hidden")

    // Focus first focusable element or the modal content itself
    // Look for elements with data-modal-focus
    const focusMe = globalModal.querySelector("[data-modal-focus]")
    if (focusMe) {
      focusMe.focus()
      return
    }
    
    // If no specific element has focus attribute, focus first focusable element
    const firstFocusable = globalModal.querySelector(this.focusableElements.join(','))
    if (firstFocusable) {
      firstFocusable.focus()
      return
    }

    // If nothing else is focusable, focus the modal content itself (with tabindex=-1)
    const modalContentElement = globalModal.querySelector('[data-modal-target="content"]')
    if (modalContentElement) {
      modalContentElement.focus()
    }
  }
}
