<conetnt-root>
  <header>Header</header>
  <article>Article</article>
  <aside>Aside</aside>
  <footer>Footer</footer>
  <style>
    :scope {
      position: absolute;
      top: 0;
      right: 0;
      left: 0;
      bottom: 0;
      margin: 0;
      padding: 0;
      display: grid;
      grid-template-rows: 50px 1fr 50px;
      grid-template-columns: 100px 1fr;
    }

    header {
      grid-row: 1 / 2;
      grid-column: 1 / 3;
    }

    aside {
      grid-row: 2 / 3;
      grid-column: 1 / 2;
    }

    article {
      grid-row: 2 / 3;
      grid-column: 2 / 3;
    }

    footer {
      grid-row: 3 / 4;
      grid-column: 1 / 3;
    }
  </style>
</conetnt-root>
