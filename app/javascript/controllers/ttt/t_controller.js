import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  connect() {
    const logo = document.querySelector('#ttt-logo');
    let width = window.innerWidth;
    let height = window.innerHeight;

    const minWght = 700;
    const maxWght = 1000;
    const minWdth = 100;
    const maxWdth = 150;
    const minGrad = 0;
    const maxGrad = 15;
    const maxTilt = 10; // Maximum tilt in degrees
    const minLetterSpacing = 0; // Minimum letter spacing (in px)
    const maxLetterSpacing = 20; // Maximum letter spacing (in px)

    window.addEventListener('mousemove', function(e) {
        // Calculate distance from center
        const xFromCenter = Math.abs(e.clientX - (width / 2));
        const yFromCenter = Math.abs(e.clientY - (height / 2));

        // Normalize distances to range [0, 1]
        const maxDistance = Math.sqrt(Math.pow(width / 2, 2) + Math.pow(height / 2, 2));
        const distanceFromCenter = Math.sqrt(Math.pow(xFromCenter, 2) + Math.pow(yFromCenter, 2)) / maxDistance;

        // Interpolate weight from maxWght to minWght
        const wght = maxWght - (distanceFromCenter * (maxWght - minWght));
        const wdth = maxWdth - (distanceFromCenter * (maxWdth - minWdth));
        const grad = minGrad + (distanceFromCenter * (maxGrad - minGrad));
        // Calculate tilt based on horizontal position
        const tilt = ((e.clientX / width) - 0.5) * -1 * maxTilt;

        // Set variation, tilt, and letter spacing
        const variation = ' "wght" ' + Math.floor(wght) + ', "wdth" ' + Math.floor(wdth) + ', "GRAD" ' + Math.floor(grad);
        logo.style.fontVariationSettings = variation;
        logo.style.transform = `rotate(${tilt}deg)`;
    })
  }
}
