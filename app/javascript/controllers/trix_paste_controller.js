import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("paste", (event) => this.pasteHandler(event))
  }

  disconnect() {
    document.removeEventListener("paste", (event) => this.pasteHandler(event))
  }

  pasteHandler(event) {
    if(document.activeElement !== this.element) {
      return;
    }

    const regex = /^(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})$/ig

    const pastedText = event.clipboardData?.getData?.("Text")
    if (!!pastedText && !!pastedText.match(regex)) {
      this.pasteUrl(pastedText)
    }
  }

  pasteUrl(pastedText) {
    const editor = this.element.editor

    let currentText = editor.getDocument().toString()
    let currentSelection = editor.getSelectedRange()
    let textWeAreInterestedIn = currentText.substring(0, currentSelection[0])
    let startOfPastedText = textWeAreInterestedIn.lastIndexOf(pastedText)
    editor.recordUndoEntry("Auto Link Paste")
    editor.setSelectedRange([startOfPastedText, currentSelection[0]])
    editor.activateAttribute('href', pastedText)
    editor.setSelectedRange(currentSelection)
  }
}
