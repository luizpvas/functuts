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
  let backToFullTextButton = document.querySelector("#back-to-full-text");
  let splitContainer = document.querySelector("#split-container");
  let tutorial = document.querySelector("#tutorial");
  let controls = document.querySelector("#sections-controls");
  let back = document.querySelector("#sections-back");
  let tracking = document.querySelector("#sections-tracking");
  let next = document.querySelector("#sections-next");

  let currentSection = 0;
  let sections = [];
  let originalChildNodes = Array.from(tutorial.childNodes);

  if (splitButton) {
    backToFullTextButton.addEventListener("click", ev => {
      tutorial.classList.remove("content--split");

      currentSection = 0;
      hideControls();
      splitContainer.style.display = "flex";

      tutorial.innerHTML = "";
      originalChildNodes.map(node => {
        tutorial.appendChild(node);
      });

      window.scrollTo(0, 0);
    });

    splitButton.addEventListener("click", ev => {
      tutorial.classList.add("content--split");

      splitContainer.style.display = "none";
      sections = [];
      let index = 0;

      originalChildNodes.map(node => {
        if (index == 0 && node.nodeType == Node.TEXT_NODE) {
          return;
        }

        if (node.tagName == "H1" || node.tagName == "H2") {
          index += 1;
          sections[index] = [node];
        } else {
          sections[index].push(node);
        }
      });

      sections = sections
        .filter(section => {
          return section.length > 0;
        })
        .map(section => {
          let container = document.createElement("div");
          container.className = "tutorial-section";
          section.map(node => container.appendChild(node));
          return container;
        });

      showControls();
      updateSection();
    });

    back.addEventListener("click", goToBack);
    next.addEventListener("click", goToNext);
  }

  function showControls() {
    controls.style.display = "block";
  }

  function hideControls() {
    controls.style.display = "none";
  }

  function goToNext() {
    currentSection = Math.min(sections.length - 1, currentSection + 1);
    updateSection();
  }

  function goToBack() {
    currentSection = Math.max(0, currentSection - 1);
    updateSection();
  }

  function updateSection() {
    tutorial.innerHTML = "";
    tutorial.appendChild(sections[currentSection]);
    updateTracking();
    window.scrollTo(0, 0);
  }

  function updateTracking() {
    tracking.innerHTML = currentSection + 1 + " / " + sections.length;
  }
}
