import "../css/app.css";
import "./prism.js";

window.addEventListener("load", ev => {
  initMenuSearch();
  initMobile();
  initSplitBySection();
});

function initMenuSearch() {
  let search = document.querySelector("#search");
  let links = Array.from(
    document.querySelectorAll('[data-target="menu-link"]')
  );

  search.addEventListener("keyup", runSearch);

  function runSearch() {
    if (search.value.length === 0) {
      links.map(link => {
        link.style.display = "block";
      });

      return;
    }

    links.map(link => {
      let containsText =
        link.textContent.toLowerCase().indexOf(search.value.toLowerCase()) ===
        -1;

      if (containsText) {
        link.style.display = "none";
      } else {
        link.style.display = "block";
      }
    });
  }
}

function initMobile() {
  let open = document.querySelector("#mobile-open-menu");
  let close = document.querySelector("#mobile-close-menu");
  let menu = document.querySelector(".menu");

  open.addEventListener("click", ev => {
    menu.style.display = "block";
    close.style.display = "block";
    open.style.display = "none";
  });

  close.addEventListener("click", ev => {
    menu.style.display = "none";
    close.style.display = "none";
    open.style.display = "block";
  });
}

function initSplitBySection() {
  let splitButton = document.querySelector("#split-by-sections");
  let tutorial = document.querySelector("#tutorial");

  if (splitButton) {
    splitButton.addEventListener("click", ev => {
      let sections = [];
      let currentSection = 0;

      Array.from(tutorial.childNodes).map(node => {
        if (currentSection == 0 && node.nodeType == Node.TEXT_NODE) {
          return;
        }

        if (node.tagName == "H1" || node.tagName == "H2") {
          sections[currentSection] = [node];
          currentSection += 1;
        } else {
          sections[currentSection].push(node);
        }
      });

      console.log(sections);
    });
  }
}
