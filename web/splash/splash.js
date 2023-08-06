function removeSplashFromWeb() {
  document.getElementById("splash")?.remove();
  document.getElementById("splash-branding")?.remove();
  document.getElementById("loader")?.remove();
  document.body.style.background = "transparent";


}
