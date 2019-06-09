import css from "../css/app.css";
import "./prism.js";

window.addEventListener("load", ev => {
  let search = document.querySelector("#search");
  let links = Array.from(
    document.querySelectorAll('[data-target="menu-link"]')
  );

  search.addEventListener("keyup", ev => {
    applySearch();
  });

  function applySearch() {
    if (search.value.length === 0) {
      links.map(link => {
        link.style.display = "block";
      });
      return;
    }

    links.map(link => {
      if (
        link.textContent.toLowerCase().indexOf(search.value.toLowerCase()) ===
        -1
      ) {
        link.style.display = "none";
      } else {
        link.style.display = "block";
      }
    });
  }

  initMobile();
});

function initMobile() {
  let open = document.querySelector('#mobile-open-menu');
  let close = document.querySelector('#mobile-close-menu');
  let menu = document.querySelector('.menu')

  open.addEventListener('click', ev => {
    menu.style.display = 'block'
    close.style.display = 'block';
    open.style.display = 'none';
  })

  close.addEventListener('click', ev => {
    menu.style.display = 'none'
    close.style.display = 'none';
    open.style.display = 'block';
  })
}