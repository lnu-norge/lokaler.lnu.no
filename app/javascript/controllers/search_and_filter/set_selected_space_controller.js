import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="set-selected-space"
export default class extends Controller {
  static targets = ["space"]

  spaceTargetConnected(target) {
    const space_id = this.spaceTarget.dataset.space
    this.setSelectedSpace(space_id)
    this.scrollToTopOfSpace()
  }

  spaceTargetDisconnected(target) {
    const space_id = this.spaceTarget.dataset.space
    this.unsetSelectedSpace(space_id)
  }

  unsetSelectedSpace = function(space_id) {
    const linkToSpace = document.querySelector(`[data-set-as-selected-when-this-space-is-open="${space_id}"]`)
    if (!linkToSpace) {
      return
    }

    linkToSpace.classList.remove('selected')
  }
  setSelectedSpace = function(space_id) {
    if (!space_id) {
      return console.error("No space id set")
    }

    const links = document.querySelectorAll(`[data-set-as-selected-when-this-space-is-open]`)
    if (!links || links.length === 0) {
      return
    }

    links.forEach((link) => {
      if (link.dataset.setAsSelectedWhenThisSpaceIsOpen === space_id) {
        link.classList.add('selected')
      } else {
        link.classList.remove('selected')
      }
    })
  }

  scrollToTopOfSpace = function() {
    const space = this.spaceTarget
    if (space) {
      space.scrollIntoView()
    }
  }
}
