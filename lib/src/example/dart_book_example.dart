part of acanvas_dartbook;

Stage stage;
DartBook book;

class DartBookExample {
  DartBookExample() {
    var opts = new StageOptions();
    opts.renderEngine = RenderEngine.Canvas2D;
    opts.backgroundColor = 0xFFf9f9f9;
    opts.stageAlign = StageAlign.TOP_LEFT;
    opts.inputEventMode =
        Ac.MOBILE ? InputEventMode.TouchOnly : InputEventMode.MouseOnly;
    opts.preventDefaultOnTouch = true;
    opts.preventDefaultOnWheel = true;
    opts.preventDefaultOnKeyboard = false;
    //opts.maxPixelRatio = 1.0;

    stage = new Stage(html.querySelector('#stage') as html.CanvasElement,
        width: 840, height: 660, options: opts);

    Ac.STAGE = stage;
    new RenderLoop()..addStage(stage);
    BookSampleAssets.load(start);
  }

  void start() {
    book = new DartBook("book");
    book.span(800, 533);
    book.x = 20;
    book.y = 60;
    book.openAt = 0;
    book.autoFlipDuration = 900;
    book.easing = 0.7;
    book.regionSize = 180;
    book.sideFlip = true;
    book.hardCover = false;
    book.hover = true;
    book.snap = false;
    book.flipOnClick = true;
    stage.addChild(book);

    /* Initialize stuff here. You can use _width and _height. */
    // first page

    Page page;
    for (int i = 1; i <= BookSampleAssets.NUM_PAGES; i++) {
      page = new Page(BookSampleAssets.getBackgroundOfPage(i));

      switch (i) {
        case 5:
        case 6:
          page.transparent = true;
          break;
        case 9:
        case 10:
          page.tearable = true;
          break;
        case 13:
          //page.liveBitmapping = true;
          break;
        case 15:
        case 16:
          page.hard = true;
          break;
      }

      book.addChild(page);
    }

    /*

  addSpriteAsPage(new MdButtons(null));
  addSpriteAsPage(new MdCheckboxes(null));
 // addSpriteAsPage(new MdDialogs(null));
  addSpriteAsPage(new MdFabs(null));
  addSpriteAsPage(new MdIconButtons(null));
  addSpriteAsPage(new MdRadioButtons(null));
  addSpriteAsPage(new MdTexts(null));
  addSpriteAsPage(new MdToasts(null));

  */

    book.addEventListener<LifecycleEvent>(
        LifecycleEvent.INIT_COMPLETE, onBookInit);
    book.addEventListener<BookEvent>(
        BookEvent.STATUS_CHANGED, onBookStatusChange);
    book.addEventListener<BookEvent>(BookEvent.PAGE_TURNED, onBookPageTurned);
    book.init();
  }

  void addSpriteAsPage(Sprite spr) {
    if (spr is Page) {
      book.addChild(spr);
    } else {
      if (spr is BoxSprite) {
        spr.inheritSpan = false;
        spr.spanWidth = 400;
        spr.spanHeight = 533;
      }

      Page p = new Page();
      p.addChild(spr);
      book.addChild(p);
    }
  }

  void onBookInit(LifecycleEvent event) {
    book.removeEventListener(LifecycleEvent.INIT_COMPLETE, onBookInit);
    // book.nextPage();
  }

  void onBookStatusChange(BookEvent event) {
    //print("NEW STATUS: ${book.status} - pageRx: ${book.pageR.x}");
  }

//SUPER EXPERIMENTAL: remove unneeded pages to save CPU/memory
  void onBookPageTurned(BookEvent event) {
    print(
        "onBookPageTurned: new left page: ${book.currentPage},  old page: ${event.page.index}");

    int renderBefore = 2;
    int renderAfter = 3;
    Page page;

    /* for transparent pages, we need to render more pages */
    if (book.currentPage > event.page.index) {
      //fwd pageturn
      page = book.getPage(book.currentPage + 3);
      if (page != null && page.transparent) {
        renderAfter = 5;
      }
    } else {
      //bwd pageturn
      page = book.getPage(book.currentPage - 2);
      if (page != null && page.transparent) {
        renderBefore = 4;
      }
    }

    for (int i = 0; i < book.pages.length; i++) {
      page = book.getPage(i);

      // filter for page range to render around index of current left page (X pages before, right page of current page, next Y pages)
      if (book.currentPage - renderBefore <= i &&
          i <= book.currentPage + renderAfter) {
        _initPage(page);

        //filter for current page and the page next to it
        if (book.currentPage - 1 <= i && i <= book.currentPage + 1) {
          if (!page.enabled) {
            page.enable();
          }
        } else {
          if (page.enabled) {
            page.disable();
          }
        }
      } else {
        page.dispose(removeSelf: false);
        page.initialized = false;
      }
    }

    //book.refreshViewStacks();
  }

  void _initPage(Page page) {
    if (page != null && !page.initialized) {
      page.init();
      page.refreshFoldGradient(false);
    }
  }
}
