# DragonFly

An attempt to build a web browser in Flutter.

> [!CAUTION]
> This project is just a proove of concept. It's not made to be really used by someone

# How does it work?

The main two things are :

- the DOM builder : The browser downloads an HTML page and parse the source code. It builds a tree containing nodes and each of them represents an HTML tag. If a tag is not supported yet, the node will be `UnkownNode`.

- the DOM drawer : It's a "basic" Flutter widget. Because each of my DOM nodes is using the `sealed class DomNode`, it's very easy to use exhaustiveness and so, I don't miss any nodes. Each node is a `Flex(axis: Axis.vertical)` to simulate a normal block tag. It's easier to manipulate a `Flex` with CSS.

- the CSS style : I have a `CSSTheme` class. It contains some CSS properties like text color, flex orientation, font size etc... I'll explain in another section how it works.

- the CSS parser : the CSS parser is not done yet... There is a CSS parser library made by the dart team that I have to use

# The CSS style

We have 3 places where we can find CSS :

- external files
- <style> tag
- style attribute


My browser has a default theme. It's defined by the W3C HTML specs.
Then I parse the external files. I merge the file theme into my initial theme.
Each DOM nodes has its 

# Will it support JS?

I would like to try to write a small JS interpreter, one that doesn't use JIT because it will be too time-consuming. I'm willing to have some recommandations, articles, links...

At least, I'd like to implement those 2 functions:

- `setTimeout`
- `document.getElementById()` -> get a special node to be able to change it's CSS

# How can I improve it?

It's a personal project with no ambitions but I'd like to have the following features:

- navigation history : I'd like to know the pages I have visited since the begining
- caching : I'd like to understand the caching rules for each file I download
- shortcuts : there's no shortcut like `ctrl+T` to create a new tab or `ctrl+TAB` to navigate trhough tabs
- favorites : the favorite bars
- mobile responsiveness : it's Flutter so it could run on mobile too
- handle more mimetypes : it only supports HTML documents. If the page we visit is only JSON, we show a JSON page. If it's an image, we show the image.

# HTML tag supported

| HTML    | Is Supported |
| ------- | ------------ |
| p       | ✅           |
| html    | ✅           |
| head    | ✅           |
| body    | ✅           |
| p       | ✅           |
| em      | ✅           |
| stromg  | ✅           |
| i       | ✅           |
| b       | ✅           |
| div     | ✅           |
| ul      | ✅           |
| ol      | ✅           |
| li      | ✅           |
| main    | ✅           |
| section | ✅           |
| footer  | ✅           |
| header  | ✅           |
| nav     | ✅           |
| title   | ✅           |
| link    | ✅           |
| a       | ✅           |
| h1      | ✅           |
| h2      | ✅           |
| h3      | ✅           |
| h4      | ✅           |
| h5      | ✅           |
| h6      | ✅           |

