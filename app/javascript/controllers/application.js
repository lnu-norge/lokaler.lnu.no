import { Application } from '@hotwired/stimulus';

const application = Application.start();

// This should only be set if we are in debug mode
if (window.RAILS_ENV === "development") {
    // Configure Stimulus development experience
    application.debug = true;
}

window.Stimulus = application;


export { application };
