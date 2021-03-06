part of acanvas_dartbook;

/**
 * Dispatched when this Page its index changes (triggered by change in the pages property of the accompanying PageManager).
 * @eventType	com.rubenswieringa.book.Page.INDEX_CHANGED
 * @see			Page#INDEX_CHANGED
 * @see			Page#index
 * @see			PageManager#pages
 * @
 */
// [Event(name="indexChanged", type="flash.events.Event")]

/**
 * A container class that stores contents of a page in the Book class.
 *
 * @author		Ruben Swieringa
 * 				ruben.swieringa@gmail.com
 * 				www.rubenswieringa.com
 * 				www.rubenswieringa.com/blog
 * @version		1.0.0
 * @see			Book Book
 *
 *
 * @internal
 *
 * edit 4
 *
 *
 * View code documentation at: dynamic  http://www.rubenswieringa.com/code/as3/flex/Book/docs/
 *
 *
 * Copyright (2005 as c) Ruben Swieringa. All rights reserved.
 *
 * This class is part of the Book component, which is licensed under the CREATIVE COMMONS Attribution 3.0 Unported.
 *   You may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at: dynamic   http://creativecommons.org/licenses/by/3.0/deed.en
 *
 */
class Page extends LifecycleSprite {
  /**
   * @
   */
  static final Map<String, num> DEFAULT_STYLES = {
    "backgroundColor": 0xFFFFFFFF,
    "backgroundAlpha": 0.3
  };

  // internals accessors:
  /**
   * @see	Page#transparent
   * @
   */
  bool _transparent = false;

  /**
   * @see	Page#tearable
   * @
   */
  bool _tearable = false;

  /**
   * @see	Page#hard
   * @
   */
  bool _hard = false;

  /**
   * @see	Page#gradients
   * @
   */
  Gradients _gradients;

  /**
   * @see	Page#book
   * @
   */
  DartBook _book;

  /**
   * @
   */
  Sprite _shape;

  /**
   * @see	Page#liveBitmapping
   * @
   */
  bool _liveBitmapping = false;

  /**
   * @see	Page#index
   * @
   */
  int _index = -1;

  // plain  properties
  /**
   * If true, this Page can not be flipped over.
   * @default	false
   */
  bool lock = false;

  // constants:
  static final int LEFT = 0;
  static final int RIGHT = 1;

  /**
   * @
   */
  static final String INDEX_CHANGED = "indexChanged";
  num _width;
  num _height;

  Bitmap bm;

  // CONSTRUCTOR:

  /**
   * Constructor
   */
  Page([this.bm = null]) : super(null) {}

  // CUSTOM:
  @override
  void init({Map<String, String> params: null}) {
    super.init(params: params);

    if (bm != null) {
      addChild(bm);
    }

    _gradients = new Gradients(this);

    _shape = new Sprite();
    addChild(_shape);

    onInitComplete();
  }

  @override
  void dispose({bool removeSelf: true}) {
    if (contains(bm))
      removeChild(bm); // save BitmapData from being trashed in super call
    _gradients = null;

    super.dispose(removeSelf: false);
  }

  @override
  void enable() {
    super.enable();
  }

  /**
   * Draws itself on a BitmapData instance and returns it.
   *
   * @return	BitmapData
   */
  BitmapData getBitmapData({bool scale: false}) {
    num mScaleX = super.width / _width;
    num mScaleY = super.height / _height;

    BitmapData bmd =
        new BitmapData(_width.round(), _height.round(), 0x00ffffff);
    Matrix matrix = new Matrix.fromIdentity();
    if (scale) matrix.scale(mScaleX, mScaleY);
    bmd.draw(this, matrix);
    return bmd;
  }

  /**
   * Draws a gradient on the folding-side of the page.
   */
  void drawFoldGradient() {
    String tint = (side == Page.LEFT) ? Gradients.LIGHT : Gradients.DARK;
    num rotate =
        (side == Page.LEFT) ? Gradients.ROTATE_FULL : Gradients.ROTATE_HALF;
    clearFoldGradient();
    _gradients.drawFold(_shape.graphics, tint, rotate);
  }

  /**
   * Erases the gradient on the folding-side of the page.
   */
  void clearFoldGradient() {
    _shape?.graphics?.clear();
  }

  /**
   * Hides fold-gradient.
   */
  void hideFoldGradient() {
    _shape?.visible = false;
  }

  /**
   * Shows fold-gradient.
   */
  void showFoldGradient() {
    _shape?.visible = true;
  }

  /**
   * Erase or draw fold gradient for this Page and the Page on the flipside (if includeFlipSide is true).
   *
   * @param	includeFlipSide	bool indicating whether or not to draw the fold-gradient for this Page its flipside.
   *
   */
  void refreshFoldGradient([bool includeFlipSide = true]) {
    // if flipside isn't available yet then don't bother trying to reach it:
    Page flipSide = getFlipSide();
    if (flipSide == null) {
      includeFlipSide = false;
    }
    // refresh fold-gradients:
    if (hard) {
      clearFoldGradient();
      if (includeFlipSide) {
        flipSide.clearFoldGradient();
      }
    } else {
      drawFoldGradient();
      if (includeFlipSide) {
        flipSide.drawFoldGradient();
      }
    }
  }

  /**
   * Tears this Page instance out of its corresponding Book.When called, this method will be executed regardless of the tearable property its value.
   *
   * @param	fromTop	If true, the Page will be torn out by its upper outer corner, if false by its lower outer corner.
   *
   * @see		Book#tearPage()
   * @see		Page#tearable
   *
   * @throws	BookError	Gets thrown when page is an index-value and out of bounds.
   * @see		BookError#OUT_OF_BOUNDS
   *
   */
  void tear([bool fromTop = true]) {
    _book.tearPage(this, fromTop);
  }

  /**
   * Returns the Page instance that is displayed on the other side of this Page.
   *
   * @return	Page
   */
  Page getFlipSide() {
    if (index == -1) {
      return null;
    }
    int i = (side == Page.LEFT) ? index - 1 : index + 1;
    if (i < 0 || i >= _book.pages.length) {
      return null;
    }
    return (_book.pages[i] as Page);
  }

  /**
   * Returns true if this is the first Page in the Book it belongs to, false otherwise.
   *
   * @return	bool indicating whether or not the Page is the first in line
   */
  bool isFirstPage() {
    if (_book == null) {
      return false;
    }
    return (_book.pages.length > 0 && this == _book.pages[0]);
  }

  /**
   * Returns true if this is the last Page in the Book it belongs to, false otherwise.
   *
   * @return	bool indicating whether or not the Page is the last in line
   */
  bool isLastPage() {
    if (_book == null) {
      return false;
    }
    return (_book.pages.length > 0 &&
        this == _book.pages[_book.pages.length - 1]);
  }

  /**
   * Re-calculates the internal for the index property of this Page instance. Typically this method is used as a listener for the contentChanged Event of the accompanying PageManager.
   * @see		BookEvent#CONTENT_CHANGED
   * @see		Page#index
   * @
   */
  void changeIndex([BookEvent event = null]) {
    _index = _book.pages.indexOf(this);
    dispatchEvent(new Event(Page.INDEX_CHANGED));
  }

  // ACCESSORS:

  /**
   * Gradients instance associated with this Page.
   * @see	Gradients
   * @
   */
  Gradients get gradients {
    return _gradients;
  }

  /**
   * Book instance with which this Page is associated. Can only be set once.
   *
   * @see	Book
   *
   */
  DartBook get book {
    return _book;
  }

  /**
   * Sets the internal for the book property.
   * @see		Page#book
   * @
   */
  void setBook(PageManager value) {
    if (value == null) {
      _book.removeEventListener<BookEvent>(
          BookEvent.CONTENT_CHANGED, changeIndex);
      _book = null;
    } else if (_book != value && value is DartBook) {
      _book = (value);
      _book.addEventListener<BookEvent>(BookEvent.CONTENT_CHANGED, changeIndex);
    }
  }

  /**
   * Indicates whether or not this Page should be hard (or as true) flexible (false). Defaults to false. Returns true if either this Page or the flipside Page has is hard..
   * @default	false
   * @see		Page#explicitHard
   */
  bool get hard {
    // if flipside has its hard property set to true then return true:
    Page flipSide = getFlipSide();
    if (flipSide != null && flipSide.explicitHard) {
      return true;
    }
    // if none of the above were true then return this Page its hard property:
    return explicitHard;
  }

  void set hard(bool value) {
    // return if there is no change in value:
    if (_hard == value) {
      return;
    }
    // set value:
    _hard = value;
    // erase or draw fold gradient for this Page and the Page on the flipside:
    refreshFoldGradient();
  }

  /**
   * Returns the hard option for this Page only, where the hard property returns true if either this Page or its flipside is hard.
   * Unless you're modifying this class you will most likely not need to use this property.
   * @default	false
   * @see		Page#hard
   */
  bool get explicitHard {
    // if hardCover is enabled in the corresponding Book and this is either the first or last Page then return true:
    if (_book != null && _book.hardCover && (isFirstPage() || isLastPage())) {
      return true;
    }
    // if none of the above were true then return this Page its hard property:
    return _hard;
  }

  /**
   * Index of this Page within the pages property of the containing Book instance.
   *
   * @see	Book#pages
   *
   */
  // [Bindable(event='indexChanged')]
  int get index {
    if (_book == null) {
      return -1;
    }
    return _book.pages.indexOf(this);
  }

  /**
   * Indicates whether or not this Page plays animation while being flipped.
   * Note that enabling liveBitmapping may result in decreased performance.
   * @default	false
   * @see		Book#lifeBitmapping
   */
  bool get liveBitmapping {
    if (_book.liveBitmapping) {
      return true;
    } else {
      return _liveBitmapping;
    }
  }

  void set liveBitmapping(bool value) {
    _liveBitmapping = value;
  }

  /**
   * int indicating on which side the Page is displayed (0=left, 1=right).
   *
   * @see	Page#LEFT
   * @see	Page#RIGHT
   *
   */
  // [Bindable(event='indexChanged')]
  int get side {
    if (_index == -1) {
      return -1;
    } else {
      return ((_index + 1) % 2);
    }
  }

  /**
   * Indicates whether or not this Page should be allowed to be be torn from its Book, false if not. Defaults to false. Returns true if either this Page or its flipside Page has is tearable, or if the Book associated with this Page has its tearable property set to true.
   * Note that even if a Page has its tearable property set to false, it can still be torn out of its Book with the tear() or tearPage() methods. This property merely indicates whether or not tearing can be achieved by dragging the page-corner manually.
   * @default	false
   * @see		Book#tearPage()
   * @see		Page#tear()
   * @see		Page#explicitTearable
   */
  bool get tearable {
    return (!hard &&
        (explicitTearable || getFlipSide().explicitTearable || _book.tearable));
  }

  void set tearable(bool value) {
    _tearable = value;
  }

  bool get transparent {
    return _transparent;
  }

  void set transparent(bool value) {
    _transparent = value;
  }

  /**
   * Returns the tearable option for this Page only, where the tearable property returns true if either this Page or its flipside is tearable.
   * Unless you're modifying this class you will most likely not need to use this property.
   * @default	false
   * @see		Page#tearable
   */
  bool get explicitTearable {
    return _tearable;
  }

  @override
  void set width(num value) {
    _width = value;
    super.width = value;
  }

  @override
  num get width {
    return _width;
  }

  @override
  void set height(num value) {
    _height = value;
    super.height = value;
  }

  @override
  num get height {
    return _height;
  }
}
